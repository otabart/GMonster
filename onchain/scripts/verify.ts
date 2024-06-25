import hre from "hardhat";

async function main() {
  await hre.run("verify:verify", {
    address: "0x8fab92ae3e74fcb2e7d0d4dab446a2c06579a744",
    constructorArguments: ["0x5F112FC646f8F166E5699CA9EAFe1fC9a9841F36"],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
