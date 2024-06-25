import hre from "hardhat";

async function main() {
  const [owner] = await hre.viem.getWalletClients();

  //current timestamp
  const timestamp = Math.floor(Date.now() / 1000);
  const GMonster = await hre.viem.deployContract("GMonster", [timestamp]);
  console.log("GMonster: ", GMonster.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
