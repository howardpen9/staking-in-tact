import { Cell, WalletContractV4, beginCell, Address, contractAddress, TonClient4, fromNano, toNano } from "ton";
import { printSeparator } from "./utils/print";

// Contract Abi //
import { buildOnchainMetadata } from "./utils/jetton-helpers";
import { mnemonicToPrivateKey } from "ton-crypto";

import { StakingContract } from "./output/SampleJetton_StakingContract";
// import { Launchpad } from "./output/SampleJetton_Launchpad";
// import { Round } from "./output/SampleJetton_Round";

import * as dotenv from "dotenv";
dotenv.config();

(async () => {
    //create client for testnet sandboxv4 API - alternative endpoint
    const client = new TonClient4({
        endpoint: "https://sandbox-v4.tonhubapi.com",
    });

    let mnemonics = (process.env.mnemonics || "").toString(); // 🔴 Change to your own
    let workchain = 0; //we are working in basechain.
    let keyPair = await mnemonicToPrivateKey(mnemonics.split(" "));
    let deploy_wallet = WalletContractV4.create({ workchain, publicKey: keyPair.publicKey });
    let deploy_wallet_contract = client.open(deploy_wallet);
    console.log("Deployer Wallet Address:  " + deploy_wallet.address);

    let jettonMaster = Address.parse("JETTON TOKEN ROOT"); // 🔴 Jetton Root, the token Address you want to support
    let staking_init = await StakingContract.init(jettonMaster, deploy_wallet_contract.address, 15000n);
    let stakingContract_address = contractAddress(workchain, staking_init);

    console.log("🔴 Checking with Staking Contract: " + stakingContract_address);
    printSeparator();

    let contract = client.open(await StakingContract.fromAddress(stakingContract_address));
    let value_StakingData = await contract.getGetReturnStakingData();
    console.log("✨ Binding JJJ's Wallet Address: " + value_StakingData.this_contract_jettonWallet);
    console.log("✨ Total Score💎: " + value_StakingData.total_score);
    console.log("✨ IndexID(# of staking Record): " + value_StakingData.index);
    console.log("✨ Parameter : " + Number(value_StakingData.parameter) / 1000);
    printSeparator();

    let list_record2 = await contract.getGetUserStakeAmount();
    if (list_record2.size > 0) {
        const keys = list_record2.keys();
        const value = list_record2.values();
        let temp_value = 0n;

        for (let i = 0; i < keys.length; i++) {
            console.log(
                "User[" +
                    i +
                    "]:" +
                    keys[i].toString() +
                    " 💎 Ratio: " +
                    Number(value[i]) / Number(value_StakingData.total_score) +
                    "\nScore: " +
                    value[i] +
                    "\n"
            );

            temp_value = BigInt(temp_value) + value[i];
        }
        console.log("💎 Total Score: " + temp_value);
    }

    printSeparator();
    let list = await contract.getGetUserStakeRecord();
    if (list.size > 0) {
        const keys = list.keys();
        const value = list.values();
        for (let i = 0; i < keys.length; i++) {
            if (value.length > 0) {
                let a = value[i].stake_address;
                let b = value[i].jjj_stake_amount;
                let c = value[i].score;
                console.log("✨Index[" + keys[i].toString() + "]:" + a + " |QTY: " + fromNano(b).toString());
                console.log("💎 Jetton | Score: " + c);
            }
        }
    }

    printSeparator();
    let value = toNano("500");
    let new_value = await contract.getGetRatioOfStake(value);
    console.log("If Stake " + fromNano(value).toString() + "| Return: " + new_value);
    console.log(" | ✨ Will roughly get: " + Number(new_value) / Number(1000000000));
    printSeparator();
    // ================================================================================ //
    // let lpd_init = await Launchpad.init(deploy_wallet.address, stakingContract_address);
    // let launchpad_contract = contractAddress(workchain, lpd_init);
    // let contract_lpd = client.open(await Launchpad.fromAddress(launchpad_contract));
    // let round_id = 0n;
    // let round_0_address = await contract_lpd.getGetRoundAddress(round_id);
    // console.log("Launchpad Address: " + launchpad_contract);
    // console.log("Round Contract: " + round_0_address);
    // console.log("Round ID: " + round_id);
    // printSeparator();
})();
