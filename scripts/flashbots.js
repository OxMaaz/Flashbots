const {
  FlashbotsBundleProvider,
} = require("@flashbots/ethers-provider-bundle");
const { BigNumber } = require("ethers");
const { ethers } = require("hardhat");
require("dotenv").config({ path: ".env" });

async function main() {
  // Deploy FakeNFT Contract
  const MrShephu = await ethers.getContractFactory("MrShephu");
  const shephu = await MrShephu.deploy();
  await shephu.deployed();

  console.log("Address of Fake NFT Contract:", shephu.address);

  // Create a Alchemy WebSocket Provider
  const provider = new ethers.providers.WebSocketProvider(
    process.env.QUICKNODE_WS_URL,
    "goerli"
  );

  // Wrap your private key in the ethers Wallet class
  const signer = new ethers.Wallet(process.env.PRIVATE_KEY, provider);

  // Create a Flashbots Provider which will forward the request to the relayer
  // Which will further send it to the flashbot miner
  const flashbotsProvider = await FlashbotsBundleProvider.create(
    provider,
    signer,
    // URL for the flashbots relayer
    "https://relay-goerli.flashbots.net",
    "goerli"
  );

  provider.on("block", async (blockNumber) => {
    console.log("Block Number: ", blockNumber);
    // Send a bundle of transactions to the flashbot relayer
    const bundleResponse = await flashbotsProvider.sendBundle(
      [
        {
          transaction: {
            // ChainId for the Goerli network
            chainId: 5,
            // EIP-1559
            type: 2,
            value: ethers.utils.parseEther("0.01"),
            to: shephu.address,
            data: shephu.interface.getSighash(" PublicMint() "),
            maxFeePerGas: BigNumber.from(10).pow(9).mul(7),
            maxPriorityFeePerGas: BigNumber.from(10).pow(9).mul(2),
          },
          signer: signer,
        },
      ],
      blockNumber++
    );

    // If an error is present, log it
    if ("error" in bundleResponse) {
      console.log(bundleResponse.error.message);
    }
  });
}

main();