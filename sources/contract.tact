import "./message.tact";
import "./jetton.tact";


/* ===========================================================================
Owing to the architectural design of TON, each token owned by an address possesses its unique 
receiving wallet address. This implies that it is not possible to input 'token contract messages' 
to be received by the token contract used for fundraising, as it would not make sense.

The correct procedure involves inputting this 'receiving contract' into the specified Jetton 
token contract to acquire the Wallet Address unique to this Jetton token. Only after obtaining 
this address can you input the message into the 'target business logic contract'.
=========================================================================== */

/*  
    1/ Need index since the the depositor might be depositing multiple times.
    2/ Each deposits might have different time frame(duration)
*/

contract StakingContract {
    this_contract_jettonWallet: Address?;
    owner: Address;
    index: Int as uint32 = 0;
    stake_record: map<Int, StakeRecord>;
    score_list: map<Address, Int>;
    start_time: Int as uint32;
    total_score: Int as uint128 = 0;
    parameter: Int as uint16;

    // TODO: 
    // jetton_root_init: InitOf;
    // get fun get_jetton_root(): Address{}
    // InitOf vs Address: Which one has lowest storage cost? 

    init(_owner: Address, _parameter: Int){
        // self.this_contract_jettonWallet = this_contract_jettonWallet;
        self.owner = _owner;
        self.parameter = _parameter;
        self.start_time = now();
    }

    // The notification for the Jetton Token contract noification(when current address receive the token will get the notification)
    receive(stake: TokenNotification){
        require(context().value >= ton("0.1"), "not enough value");
        
        // Check the sender is from the Jetton Wallet
        require(context().sender == self.this_contract_jettonWallet, "not from one of any jetton wallet");
        
        // Manipulating the score you want to give, no matter based on time or amount
        let score: Int = self.score_function(stake.amount);
        
        // Update the stake record
        self.stake_record.set(self.index,
            StakeRecord{
                stake_address: stake.from, 
                jettonStakeAmount: stake.amount, 
                score: score
            }
        );

        // Update the weight of the user, if the user is in the list, then add it
        let previous_score: Int = self.score_list.get(stake.from)!!;
        if (previous_score == null) {
            self.score_list.set(stake.from, score);
        } else if (previous_score >= 0) {
            previous_score = (previous_score + score);
            self.score_list.set(stake.from, previous_score);
        }
        self.total_score = (self.total_score + score);
        self.index = (self.index + 1);

        // Submit the Log Event
        emit(TransferEvent{sender_address: stake.from, jetton_amount: stake.amount, score: score}.toCell());
    }

    // To get the ratio of a user in a on-chain ways
    receive(msg: GetWeighted){
        let ctx: Context = context();
        let user_score: Int = self.score_list.get(msg.applied_user_address)!!;
        require(user_score > 0, "no Record");
        send(SendParameters{
                to: ctx.sender,
                value: 0,
                mode: (SendRemainingValue + SendIgnoreErrors),
                bounce: true,
                body: PassScoreToRoundContract{
                    checked_address: msg.applied_user_address, // 0xe5fd7f29
                    return_score: user_score
                }.toCell()
            }
        );
    }

    // receive(msg: AdminExecute) {}

    receive(msg: Unstake){
        let weight: Int = self.score_list.get(context().sender)!!;
        require(weight > 0, "not in the list"); // TODO: only checking point

        // Send Transfer to self.get_major_jetton_address(myAddress())
        // Transfer the jetton token back: Amount, who
        let stake_record: StakeRecord = self.stake_record.get(msg.index_id)!!;
        require(stake_record.jettonStakeAmount > 0, "don't have value");
        self.stake_record.set(msg.index_id, null);
        send(SendParameters{
                to: self.this_contract_jettonWallet!!,
                value: 0,
                mode: (SendRemainingValue + SendIgnoreErrors),
                bounce: false, // 0x7362d09c - notify new owner
                body: TokenTransfer{
                    query_id: 0,
                    amount: stake_record.jettonStakeAmount,
                    destination: context().sender,
                    response_destination: myAddress(),
                    custom_payload: null,
                    forward_ton_amount: ton("0.01"),
                    forward_payload: emptySlice()
                }.toCell()
            }
        );
    }

    fun score_function(jetton_amount: Int): Int {         
        return (jetton_amount * pow(10, 18) / self.durationTime() * self.parameter / 1000); 
    }

    fun durationTime(): Int {
        return now() - self.start_time;
    }

    // TODO: Admin 強制 UnStake所有代幣？
    // admin enable to withdraw the token to the original depositor

    receive(){}

    get fun get_user_stake_record(): map<Int, StakeRecord> {
        return self.stake_record;
    }

    get fun get_user_stake_amount(): map<Address, Int> {
        return self.score_list;
    }

    get fun get_return_staking_data(): StakingData {
        return
            StakingData{
                index: self.index,
                this_contract_jettonWallet: self.this_contract_jettonWallet!!,
                total_score: self.total_score,
                parameter: self.parameter
            };
    }

     // get fun get_ratio_of_stake(StakeTokenAmount: Int): Int {
    //     return self.score_function(StakeTokenAmount) * pow(10, 9) / self.total_score;
    // }
    // get fun get_ratio_of_stake_2(StakeTokenAmount: Int): Int {
    //     return self.score_function(StakeTokenAmount) * pow(10, 6) / self.total_score;
    // }
    // get fun get_ratio_of_stake_3(StakeTokenAmount: Int): Int {
    //     return self.score_function(StakeTokenAmount) * 100 / self.total_score / 100;
    // }
}
