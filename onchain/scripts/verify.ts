import hre from "hardhat";

async function main() {
  await hre.run("verify:verify", {
    address: "0xe6c0a86ba34892e116c6ecf2352a94fe0ac6bcc3",
    constructorArguments: ["0x6C4502B639ab01Cb499cEcCA7D84EB21Fde928F8"],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
