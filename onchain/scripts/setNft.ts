import hre from "hardhat";

async function main() {
  const gmon = await hre.viem.getContractAt(
    "GMonster",
    "0x5F112FC646f8F166E5699CA9EAFe1fC9a9841F36"
  );

  const tx = await gmon.write.setNft([
    "0x8fab92ae3e74fcb2e7d0d4dab446a2c06579a744",
  ]);
  console.log("tx: ", tx);
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
