import { toNano, Address, JettonMaster, TonClient, beginCell, TonClient4 } from "ton";
import {
    Blockchain,
    SandboxContract,
    TreasuryContract,
    printTransactionFees,
    prettyLogTransactions,
    RemoteBlockchainStorage,
    wrapTonClient4ForRemote,
} from "@ton-community/sandbox";
import "@ton-community/test-utils";
import { getHttpEndpoint } from "@orbs-network/ton-access";
// import { ContractSystem } from "@tact-lang/emulator";

// ---------------------------------------------------------------------------------
import { StakingContract } from "./output/SampleJetton_StakingContract";
import { SampleJetton } from "./output/SampleJetton_SampleJetton";
import exp from "constants";
// ---------------------------------------------------------------------------------

// const endpoint = await getHttpEndpoint();
// const client = new TonClient({ endpoint });

describe("==== contract Testing ====", () => {
    let blockchain: Blockchain;
    let deployer: SandboxContract<TreasuryContract>;
    let nonOwner: SandboxContract<TreasuryContract>;
    let contract: SandboxContract<StakingContract>;
    let jettonContract: SandboxContract<SampleJetton>;

    // const client4 = new TonClient4({
    //     endpoint: "https://sandbox-v4.tonhubapi.com",
    // });
    // let cc = client4.open(jettonMaster);

    beforeAll(async () => {
        blockchain = await Blockchain.create();
        deployer = await blockchain.treasury("deployer");

        // Setting the Jetton Token Root //
        jettonContract = await blockchain.openContract(
            await SampleJetton.fromInit(deployer.address, beginCell().endCell(), 200n)
        );
        const jettonMaster = JettonMaster.create(jettonContract.address);
        // ------------------------------------------------------------

        contract = blockchain.openContract(await StakingContract.fromInit(deployer.address, 200n));
        console.log("StakingAddress: " + contract.address);

        const jettonDeployResult = await jettonContract.send(deployer.getSender(), { value: toNano(1) }, "Mint: 100");
        expect(jettonDeployResult.transactions).toHaveTransaction({
            from: deployer.address,
            to: jettonContract.address,
            deploy: true,
            success: true,
        });

        let stakingContract_jettonWallet = await jettonContract.getGetWalletAddress(contract.address);
        console.log("StakingAddress's JettonWallet: " + stakingContract_jettonWallet);
    });

    it("Test", async () => {
        let contractAddress = await contract.address;
        expect(contractAddress).toBeDefined();

        let jettonContractAddr = await jettonContract.address;
        expect(jettonContractAddr).toBeDefined();
    });

    it("Create The Jetton Deposit", async () => {
        //
    });
});
