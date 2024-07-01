import hre from "hardhat";

async function main() {
  // const [owner] = await hre.viem.getWalletClients();

  //July 6th 9:00 (GMT+0) timestamp
  const timestamp = Date.UTC(2024, 6, 5, 21, 30) / 1000;
  console.log("timestamp: ", timestamp);
  const GMonster = await hre.viem.deployContract("GMonster", [timestamp]);
  console.log("GMonster: ", GMonster.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
