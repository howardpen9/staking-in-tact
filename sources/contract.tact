// ===== TEP64 Standard: Jetton Messages ===== //
message TokenTransfer {
    queryId: Int as uint64;
    amount: Int as coins;
    destination: Address;
    response_destination: Address;
    custom_payload: Cell?;
    forward_ton_amount: Int as coins;
    forward_payload: Slice as remaining;
}
message TokenNotification {
    queryId: Int as uint64;
    amount: Int as coins;
    from: Address;
    forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton
}

// For the end-point of the Tx, this data means nothing important.
// (Ref: https://github.com/ton-blockchain/TEPs/blob/master/text/0074-jettons-standard.md)
// ===== LOG Event ===== //
message TransferEvent {
    sender_address: Address;
    jetton_amount: Int as coins;
    score: Int as uint128;
}
// ================================================================================ //
message AddingJettonAddress {
    this_contract_jettonWallet: Address;
}
message Unstake {
    index_id: Int as uint32;
}
message Redeem {
    queryId: Int as uint64;
    project_id: Int as uint16;
}
message GetWeighted {
    // ===== on-chain fetch ===== //
    applied_user_address: Address;
}

/*  ================================================================================
    1/ Need index since the the depositor might be depositing multiple times.
    2/ Each deposits might have different time frame(duration)

    TODO: 單個 Staking 合約支持多種代幣質押的可能性？                                      
*/
contract StakingContract {
    this_contract_jettonWallet: Address;
    owner: Address;

    index: Int as uint32 = 0;
    stake_record: map<Int, StakeRecord>;
    score_list: map<Address, Int>;
    start_time: Int as uint32;
    total_score: Int as uint128 = 0;
    parameter: Int as uint16;
    init(this_contract_jettonWallet: Address, _owner: Address, parameter: Int){
        self.this_contract_jettonWallet = this_contract_jettonWallet;
        self.owner = _owner;
        self.parameter = parameter;
        self.start_time = now();
    }

    // 1️⃣-step 🔴 Admin: Initially add the Jetton Token Wallet Address,
    // We need to pass the Current Contract's JettonWallet Address to activate it.
    // There has some benefits by doing so, since your staking contract wouldn't "Front-Run".
    // Second part is that, Jetton Token's Wallet Address we got through `ton-core` library, is only works for FunC's JettonWallet code.
    receive(msg: AddingJettonAddress){
        let ctx: Context = context();
        require(ctx.sender == self.owner, "not from owner");
        self.this_contract_jettonWallet = msg.this_contract_jettonWallet;
        self.forward(ctx.sender, "Success".asComment(), false, null);
    }

    // 2️⃣ 正常收款時、由此訊息判斷
    receive(stake: TokenNotification){
        let ctx: Context = context();
        require(ctx.sender == self.this_contract_jettonWallet, "not from one of any jetton wallet");
        let score: Int = self.score_function(stake.amount);
        self.stake_record.set(self.index,
            StakeRecord{stake_address: stake.from, jjj_stake_amount: stake.amount, score: score}
        );
        // Update the weight
        let previous_score: Int = self.score_list.get(stake.from)!!;
        if (previous_score == null) {
            self.score_list.set(stake.from, score);
        } else if (previous_score >= 0) {
            previous_score = previous_score + score;
            self.score_list.set(stake.from, previous_score);
        }
        // Submit the Log Event
        emit(TransferEvent{sender_address: stake.from, jetton_amount: stake.amount, score: score}.toCell());
        self.total_score = self.total_score + score;
        self.index = self.index + 1;
    }

    // receive(msg: ChangeParater) { // TODO
    //     self.parameter = msg.parameter;
    // }

     fun score_function(jjj_amount: Int): Int {
        return jjj_amount * pow(10, 18) / now() - self.start_time * self.parameter / 1000; // 15000 / 1000
        // TODO: 解釋時間權重在早期的影響力過大的問題
    }

    get fun get_ratio_of_stake(StakeTokenAmount: Int): Int {
        return self.score_function(StakeTokenAmount) * pow(10, 9) / self.total_score;
    }

    get fun get_ratio_of_stake_2(StakeTokenAmount: Int): Int {
        return self.score_function(StakeTokenAmount) * pow(10, 6) / self.total_score;
    }

    get fun get_ratio_of_stake_3(StakeTokenAmount: Int): Int {
        return self.score_function(StakeTokenAmount) * 100 / self.total_score / 100;
    }

    // To get the ratio of a user in a on-chain ways
    receive(msg: GetWeighted){
        let ctx: Context = context();
        let user_score: Int = self.score_list.get(msg.applied_user_address)!!;
        require(user_score > 0, "no Record");
        send(SendParameters{to: ctx.sender,
                value: 0,
                mode: SendRemainingValue + SendIgnoreErrors,
                bounce: true,
                body: PassScoreToRoundContract{checked_address: msg.applied_user_address, // 0xe5fd7f29
                    return_score: user_score
                }.toCell()
            }
        );
    }

    // receive(msg: AdminExecute) {}

    receive(msg: Unstake){
        // TODO
        let ctx: Context = context();
        let ww: Int = self.score_list.get(ctx.sender)!!;
        require(ww > 0, "not in the list"); // TODO: only checking point

        // Send Transfer to self.get_major_jetton_address(myAddress())
        // Transfer the jetton token back: Amount, who
        let stake_record: StakeRecord = self.stake_record.get(msg.index_id)!!;
        require(stake_record.jjj_stake_amount > 0, "don't have value");
        self.stake_record.set(msg.index_id, null);
        send(SendParameters{to: self.this_contract_jettonWallet,
                value: 0,
                mode: SendRemainingValue + SendIgnoreErrors,
                bounce: false, // 0x7362d09c - notify new owner
                body: TokenTransfer{queryId: 0,
                    amount: stake_record.jjj_stake_amount,
                    destination: ctx.sender,
                    response_destination: myAddress(),
                    custom_payload: null,
                    forward_ton_amount: ton("0.01"),
                    forward_payload: emptySlice()
                }.toCell()
            }
        );

    }

    // TODO: Admin 強制 UnStake所有代幣？
    // admin enable to withdraw the token to the original depositor

    receive(){}

    get fun get_user_stake_record(): map<Int, StakeRecord> {
        return self.stake_record;
    }

    get fun get_user_stake_amount(): map<Address ,Int> {
        return self.score_list;
    }

    get fun get_return_staking_data(): StakingData {
        return
            StakingData{index: self.index,
                this_contract_jettonWallet: self.this_contract_jettonWallet,
                total_score: self.total_score,
                parameter: self.parameter
            };
    }
}
// ===== Data Struct ===== //
struct StakingData {
    index: Int as uint64;
    this_contract_jettonWallet: Address;
    total_score: Int as coins;
    parameter: Int as uint16;
}
struct StakeRecord {
    stake_address: Address;
    jjj_stake_amount: Int as coins;
    score: Int as uint128; // TODO: 可以後面刪掉
}

/* ===========================================================================
Due to the architectural design of TON, "each token owned by an address has its own independent receiving wallet address."
This means you cannot input "token contract messages that can be received into the token contract used for fundraising.
It doesn't make sense."

The actual process is that you must input this "receiving contract" into the target Jetton token contract
and obtain the Wallet Address exclusive to this Jetton token. Only then can you input this message into 
the "target business logic contract".
=========================================================================== */
message PassScoreToRoundContract {
    checked_address: Address;
    return_score: Int as uint64;
}