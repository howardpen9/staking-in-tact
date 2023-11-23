message PassScoreToRoundContract {
    checked_address: Address;
    return_score: Int as uint64;
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
    jettonStakeAmount: Int as coins;
    score: Int as uint128; // TODO: 可以後面刪掉
}
// ===== TEP64 Standard: Jetton Messages ===== //
// message(0xf8a7ea5) TokenTransfer {
//     query_id: Int as uint64;
//     amount: Int as coins;
//     destination: Address;
//     response_destination: Address;
//     custom_payload: Cell?;
//     forward_ton_amount: Int as coins;
//     forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton
// }

// message(0x7362d09c) TokenNotification {
//     query_id: Int as uint64;
//     amount: Int as coins;
//     from: Address;
//     forward_payload: Slice as remaining; // Comment Text message when Transfer the jetton 
// }


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