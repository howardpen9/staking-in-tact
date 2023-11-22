# TACT Compilation Report
Contract: StakingContract
BOC Size: 2059 bytes

# Types
Total Types: 13

## StateInit
TLB: `_ code:^cell data:^cell = StateInit`
Signature: `StateInit{code:^cell,data:^cell}`

## Context
TLB: `_ bounced:bool sender:address value:int257 raw:^slice = Context`
Signature: `Context{bounced:bool,sender:address,value:int257,raw:^slice}`

## SendParameters
TLB: `_ bounce:bool to:address value:int257 mode:int257 body:Maybe ^cell code:Maybe ^cell data:Maybe ^cell = SendParameters`
Signature: `SendParameters{bounce:bool,to:address,value:int257,mode:int257,body:Maybe ^cell,code:Maybe ^cell,data:Maybe ^cell}`

## PassScoreToRoundContract
TLB: `pass_score_to_round_contract#e5fd7f29 checked_address:address return_score:uint64 = PassScoreToRoundContract`
Signature: `PassScoreToRoundContract{checked_address:address,return_score:uint64}`

## StakingData
TLB: `_ index:uint64 this_contract_jettonWallet:address total_score:coins parameter:uint16 = StakingData`
Signature: `StakingData{index:uint64,this_contract_jettonWallet:address,total_score:coins,parameter:uint16}`

## StakeRecord
TLB: `_ stake_address:address jettonStakeAmount:coins score:uint128 = StakeRecord`
Signature: `StakeRecord{stake_address:address,jettonStakeAmount:coins,score:uint128}`

## TokenTransfer
TLB: `token_transfer#e54bcffe queryId:uint64 amount:coins destination:address response_destination:address custom_payload:Maybe ^cell forward_ton_amount:coins forward_payload:remainder<slice> = TokenTransfer`
Signature: `TokenTransfer{queryId:uint64,amount:coins,destination:address,response_destination:address,custom_payload:Maybe ^cell,forward_ton_amount:coins,forward_payload:remainder<slice>}`

## TokenNotification
TLB: `token_notification#ad2c4ac6 queryId:uint64 amount:coins from:address forward_payload:remainder<slice> = TokenNotification`
Signature: `TokenNotification{queryId:uint64,amount:coins,from:address,forward_payload:remainder<slice>}`

## TransferEvent
TLB: `transfer_event#526bed5b sender_address:address jetton_amount:coins score:uint128 = TransferEvent`
Signature: `TransferEvent{sender_address:address,jetton_amount:coins,score:uint128}`

## AddingJettonAddress
TLB: `adding_jetton_address#022702dd this_contract_jettonWallet:address = AddingJettonAddress`
Signature: `AddingJettonAddress{this_contract_jettonWallet:address}`

## Unstake
TLB: `unstake#8515738f index_id:uint32 = Unstake`
Signature: `Unstake{index_id:uint32}`

## Redeem
TLB: `redeem#4a906188 queryId:uint64 project_id:uint16 = Redeem`
Signature: `Redeem{queryId:uint64,project_id:uint16}`

## GetWeighted
TLB: `get_weighted#134c687a applied_user_address:address = GetWeighted`
Signature: `GetWeighted{applied_user_address:address}`

# Get Methods
Total Get Methods: 6

## get_ratio_of_stake
Argument: StakeTokenAmount

## get_ratio_of_stake_2
Argument: StakeTokenAmount

## get_ratio_of_stake_3
Argument: StakeTokenAmount

## get_user_stake_record

## get_user_stake_amount

## get_return_staking_data

# Error Codes
2: Stack undeflow
3: Stack overflow
4: Integer overflow
5: Integer out of expected range
6: Invalid opcode
7: Type check error
8: Cell overflow
9: Cell underflow
10: Dictionary error
13: Out of gas error
32: Method ID not found
34: Action is invalid or not supported
37: Not enough TON
38: Not enough extra-currencies
128: Null reference exception
129: Invalid serialization prefix
130: Invalid incoming message
131: Constraints error
132: Access denied
133: Contract stopped
134: Invalid argument
135: Code of a contract was not found
136: Invalid address
137: Masterchain support is not enabled for this contract
6582: no Record
7013: don't have value
17054: not from one of any jetton wallet
57218: not enough value
57660: not in the list