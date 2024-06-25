import hre from "hardhat";

async function main() {
  // const [owner] = await hre.viem.getWalletClients();

  const GMonsterNFT = await hre.viem.deployContract("GMonsterNFT", [
    "0x5F112FC646f8F166E5699CA9EAFe1fC9a9841F36",
  ]);
  console.log("GMonsterNFT: ", GMonsterNFT.address);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
