import hre from "hardhat";

async function main() {
  const timestamp = Date.UTC(2024, 6, 5, 21, 30) / 1000;
  await hre.run("verify:verify", {
    address: "0x9d44492232ad68dfd71c4c66510f0a3e0fa1307c",
    constructorArguments: [timestamp],
  });
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
