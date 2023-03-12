// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import "forge-std/StdAssertions.sol";
import "forge-std/console2.sol";
import "forge-std/StdAssertions.sol";
import "forge-std/Test.sol";
import 'contracts/BukSupplierDeployer.sol';

contract BukSupplierDeployerTest is Test {
    address factoryContract = address(0x1);
    address admin = address(0x2);
    address treasury = address(0x3);
    BukSupplierDeployer bukSupplierDeployer;

    function setUp() public {
      vm.prank(admin);
      bukSupplierDeployer = new BukSupplierDeployer(factoryContract);
    }

    //Need to make factoryContract public to execute this test
    function testUpdateFactory() public {
      vm.prank(admin);
      bukSupplierDeployer.updateFactory(address(0x0));
      // address newFactoryContract = bukSupplierDeployer.factoryContract();
      // assertEq(newFactoryContract, address(0x0));
    }

    function testDeploySupplier() public {
      vm.prank(factoryContract);
      uint256 id = 1;
      address supplierOwner = address(0x4);
      address utilityContract = address(0x5);
      address supplier = bukSupplierDeployer.deploySupplier(
        "BukTrips.com Powered by Expedia",
        id,
        0x457870656469612047726f757020496e632e0000000000000000000000000000,
        supplierOwner, 
        utilityContract,
        "ipfs://ips_cid"
        );
    }
}
