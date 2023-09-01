import {
    beginCell,
    contractAddress,
    toNano,
    TonClient4,
    Address,
    WalletContractV4,
    internal,
    fromNano,
    JettonMaster,
} from "ton";
import { mnemonicToPrivateKey } from "ton-crypto";
import { StakingContract, storeAddingJettonAddress } from "./output/SampleJetton_StakingContract";
import { printSeparator } from "./utils/print";
import * as dotenv from "dotenv";
dotenv.config();

(async () => {
    //create client for testnet sandboxv4 API - alternative endpoint
    const client = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com", // Test_net::
    });

    let mnemonics = (process.env.mnemonics || "").toString(); // 🔴 Change to your own
    let workchain = 0; //we are working in basechain.
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" "));
    let deployer_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    let deployer_wallet_contract = client.open(deployer_wallet);
    console.log("🛠️ Preparing new outgoing massage from deployment wallet:\n" + deployer_wallet_contract.address);
    printSeparator();

    // let jettonMaster_address = Address.parse("JETTON TOKEN ROOT"); // 🔴 Jetton Root, the token Address you want to support
    let jettonMaster_address = Address.parse("EQB0EN3UlNiAEj18cN7qs7rF4rvLKtQ2-bkjMZN4w5A13lXA");
    let staking_init = await StakingContract.init(jettonMaster_address, deployer_wallet.address, 15000n);
    let stakingContract = contractAddress(workchain, staking_init); // Get Address of the Staking Contract
    let deployAmount = toNano("0.1");
    let jetton_client = client.open(await new JettonMaster(jettonMaster_address));
    let jettonWallet_stakingContract = await jetton_client.getWalletAddress(stakingContract);
    console.log("🔴 StakingContract's JettonWallet: \n" + jettonWallet_stakingContract);
    console.log("(Based on JettonMinter:" + jettonMaster_address + ")");

    // send a message on new address contract to deploy it
    let seqno: number = await deployer_wallet_contract.getSeqno();
    let balance: bigint = await deployer_wallet_contract.getBalance();
    console.log("Current deployment wallet balance = ", fromNano(balance).toString(), "💎TON");
    printSeparator();
    console.log("Deploying the Staking Contract:");
    console.log("1) Jetton Minter: " + jettonMaster_address);
    console.log("\n");
    console.log("2) Owner(aka. Deployer): " + deployer_wallet.address);
    console.log("\n");

    // the TL-B Message that we are preparing to pass to the contract
    let packed = beginCell()
        .store(
            storeAddingJettonAddress({
                $$type: "AddingJettonAddress",
                this_contract_jettonWallet: jettonWallet_stakingContract,
            })
        )
        .endCell();

    await deployer_wallet_contract.sendTransfer({
        seqno,
        secretKey: keyPair.secretKey,
        messages: [
            internal({
                to: stakingContract,
                value: deployAmount,
                init: {
                    code: staking_init.code,
                    data: staking_init.data,
                },
                body: packed,
            }),
        ],
    });
    console.log("====== Message sending to Staking Contract=======");
    console.log("\n" + stakingContract);
})();
