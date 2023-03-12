import * as hre from "hardhat";
import { CONTRACT } from "../utils/config";
import { utils } from "ethers"
import { Web3Service } from "../utils/functions/web3";

async function main() {

  const supplierName = "BukTrips.com Powered by Expedia"
  const name = utils.formatBytes32String("BukTrips.com Powered by Expedia")
  // const name = "0x42756b54726970732e636f6d20506f7765726564206279204578706564696100"
  const data = {
    id: 1,
    name,
    contractName: supplierName,
    uri: "https://ipfs.io/ipfs/bafkreiatlnjlu5kq3ixdpoyxgqyvh2pm3bxovnaay5qvkjc536pqv4geay",
  }

  //Verify Supplier Contract
  await hre.run("verify:verify", {
    address: CONTRACT.SUPPLIER_CONTRACT,
    contract: "contracts/SupplierContract.sol:SupplierContract",
    constructorArguments: [
      data.contractName,
      data.id,
      data.name,
      CONTRACT.ADMIN_WALLET,
      CONTRACT.SUPPLIER_UTILITY_CONTRACT,
      CONTRACT.FACTORY_CONTRACT,
      data.uri
    ],
  });

  //Verify Supplier Utility Contract
  await hre.run("verify:verify", {
    address: CONTRACT.SUPPLIER_UTILITY_CONTRACT,
    contract: "contracts/SupplierUtilityContract.sol:SupplierUtilityContract",
    constructorArguments: [
      data.contractName,
      data.id,
      data.name,
      CONTRACT.FACTORY_CONTRACT,
      data.uri
    ],
  });

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
