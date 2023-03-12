// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import "forge-std/Test.sol";
import "forge-std/StdAssertions.sol";
import 'contracts/BukSupplierUtilityDeployer.sol';

contract BukSupplierUtilityDeployerTest is Test {
    address factoryContract = address(0x1);
    address admin = address(0x2);
    BukSupplierUtilityDeployer bukSupplierUtilityDeployer;

    function setUp() public {
      vm.prank(admin);
      bukSupplierUtilityDeployer = new BukSupplierUtilityDeployer(factoryContract);
    }
    //Need to make factoryContract public to execute this test
    function testUpdateFactory() public {
      vm.prank(admin);
      bukSupplierUtilityDeployer.updateFactory(address(0x0));
      // address newFactoryContract = bukSupplierUtilityDeployer.factoryContract();
      // assertEq(newFactoryContract, address(0x0));
    }

    function testDeploySupplierUtility() public {
      vm.prank(factoryContract);
      uint256 id = 1;
      address supplierOwner = address(0x4);
      address utilityContract = address(0x5);
      address supplier = bukSupplierUtilityDeployer.deploySupplierUtility(
        "BukTrips.com Powered by Expedia",
        id,
        0x457870656469612047726f757020496e632e0000000000000000000000000000,
        "ipfs://ips_cid"
        );
    }
}
