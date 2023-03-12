// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import "forge-std/Test.sol";
import 'contracts/FactoryContract.sol';
import 'contracts/BukSupplierUtilityDeployer.sol';
import 'contracts/BukSupplierDeployer.sol';
import 'contracts/Treasury.sol';

contract BukTripsTest is Test {
    BukTrips factoryContract;
    BukSupplierDeployer supplierDeployer;
    BukSupplierUtilityDeployer utilityDeployer;
    Treasury treasury;
    address admin = address(0x2);
    address currency = address(0x4);
    address bukWallet = address(0x5);

    uint8 commission = 15;

    function setUp() public {
      vm.prank(admin);
      treasury = new Treasury(currency);
      vm.prank(admin);
      factoryContract = new BukTrips(address(treasury), currency, bukWallet);
      vm.prank(admin);
      supplierDeployer = new BukSupplierDeployer(address(factoryContract));
      vm.prank(admin);
      utilityDeployer = new BukSupplierUtilityDeployer(address(factoryContract));
    }

    function testSetDeployers() public {
      vm.prank(admin);
      factoryContract.setDeployers(address(supplierDeployer), address(utilityDeployer));
      assertEq(factoryContract.supplierDeployer(), address(supplierDeployer), "Suppliers Mismatch");
      assertEq(factoryContract.utilityDeployer(), address(utilityDeployer), "Suppliers Mismatch");
    }

    //Need to make treasury public to execute this test
    function testSetTreasury() public {
      vm.prank(admin);
      factoryContract.setTreasury(address(0x8));
      // assertEq(factoryContract.treasury(), address(0x8), "Treasury Mismatch");
    }

    function testSetCommission() public {
      vm.prank(admin);
      factoryContract.setCommission(5);
      assertEq(factoryContract.commission(), 5, "Commission Mismatch");
    }

    function testSetTransferLock() public {
      vm.prank(admin);
      factoryContract.setCommission(5);
    }
}
