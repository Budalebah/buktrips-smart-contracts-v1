// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import "forge-std/Test.sol";
import "forge-std/Script.sol";
import "forge-std/console.sol";
import 'contracts/FactoryContract.sol';
import 'contracts/BukSupplierUtilityDeployer.sol';
import 'contracts/BukSupplierDeployer.sol';
import 'contracts/Treasury.sol';
import '../SampleCurrency.sol';
import 'contracts/SupplierContract.sol';
import 'contracts/SupplierUtilityContract.sol';

contract BukTripsTest is Test {
    BukTrips factoryContract;
    BukSupplierDeployer supplierDeployer;
    BukSupplierUtilityDeployer utilityDeployer;
    SupplierContract supplierContract;
    SupplierUtilityContract utilityContract;
    Treasury treasury;
    Currency currency;
    address admin = address(0x2);
    address bukWallet = address(0x5);
    uint8 commission = 5;
    address alice = address(0x9);

    function setUp() public {
      //Deploy ERC20 
      vm.prank(admin);
      currency = new Currency();

      //Mint ERC20 to Alice's wallet
      vm.prank(admin);
      currency.mint(alice, 10000000000);

      //Deploy Treasury contract
      vm.prank(admin);
      treasury = new Treasury(address(currency));

      //Deploy Facory contract
      vm.prank(admin);
      factoryContract = new BukTrips(address(treasury), address(currency), bukWallet);

      //Deploy Supplier Deployer contract
      vm.prank(admin);
      supplierDeployer = new BukSupplierDeployer(address(factoryContract));

      //Deploy Supplier Utility Deployer contract
      vm.prank(admin);
      utilityDeployer = new BukSupplierUtilityDeployer(address(factoryContract));
    }

    function testBooking() public {

      //To Set the Deployers in Factory Contract
      vm.prank(admin);
      factoryContract.setDeployers(address(supplierDeployer), address(utilityDeployer));

      //To Set Factory contract in Treasury
      vm.prank(admin);
      treasury.setFactory(address(factoryContract));

      //To Register a Supplier
      vm.prank(admin);
      (uint256 supplierId, address supplierContractAddr, address utilityContractAddr) = factoryContract.registerSupplier(
        "BukTrips.com", 
        0x457870656469612047726f757020496e632e0000000000000000000000000000,
        address(0x3), 
        "contract uri");
      supplierContract = SupplierContract(supplierContractAddr);
      utilityContract = SupplierUtilityContract(utilityContractAddr);
      
      //Update Supplier Details
      vm.prank(admin);
      factoryContract.updateSupplierDetails(
        1, 
        "BukTrips.com1",
        0x457870656469612047726f757020496e632e0000000000000000000000000000
        );

      assertEq(supplierContract.name(), "BukTrips.com1");

      //To Approve currency for booking
      vm.prank(alice);
      currency.approve(address(factoryContract), 150000000);
      
      //To Book Room by Alice
      vm.prank(alice);
      uint256 count = 4;
      uint256[] memory total = new uint256[](count);
      total[0] = (uint256(20000000));
      total[1] = (uint256(28000000));
      total[2] = (uint256(36000000));
      total[3] = (uint256(36000000));
      uint256[] memory baseRate = new uint256[](count);
      baseRate[0] = (uint256(2500000));
      baseRate[1] = (uint256(3900000));
      baseRate[2] = (uint256(5800000));
      baseRate[3] = (uint256(5800000));
      factoryContract.bookRoom(1, count, total, baseRate, 1678579200, 1679011200);
      checkBookingStatus(2, 28000000, 3900000, BukTrips.BookingStatus.booked);
      uint256 totalFee = total[0] + total[1] + total[2] + total[3];
      uint256 commissionTotal = (baseRate[0]*commission/100 + baseRate[1]*commission/100 + baseRate[2]*commission/100 + baseRate[3]*commission/100);
      assertEq(currency.balanceOf(address(treasury)), totalFee);
      assertEq(currency.balanceOf(address(bukWallet)), commissionTotal);

      //To Confirm Room and mint NFT by Alice
      uint256[] memory ids1 = new uint256[](1);
      ids1[0] = uint256(1);
      uint256[] memory ids2 = new uint256[](1);
      ids2[0] = uint256(2);
      uint256[] memory ids3 = new uint256[](1);
      ids3[0] = uint256(3);
      uint256[] memory ids4 = new uint256[](1);
      ids4[0] = uint256(4);
      string[] memory uris = new string[](1);
      uris[0] = "token uri";
      vm.prank(alice);
      factoryContract.confirmRoom(1, ids1, uris, false);
      vm.prank(alice);
      factoryContract.confirmRoom(1, ids2, uris, false);
      checkBookingStatus(1, total[0], baseRate[0], BukTrips.BookingStatus.confirmed);
      assertEq(supplierContract.uri(1), "token uri");

      //NFT Transfer
      bytes memory data = "";
      // supplierContract.safeTransferFrom(alice, bukWallet, 1, 1, data);
      vm.prank(admin);
      factoryContract.toggleNFTStatus(1, true);
      vm.prank(admin);
      factoryContract.toggleNFTStatus(2, true);
      uint256[] memory transferIds = new uint256[](2);
      transferIds[0] = (uint256(1));
      transferIds[1] = (uint256(2));
      uint256[] memory transferAmts = new uint256[](2);
      transferAmts[0] = (uint256(1));
      transferAmts[1] = (uint256(1));
      assertEq(supplierContract.balanceOf(alice, 1), 1, "No balance NFT to transfer");
      vm.prank(alice);
      // supplierContract.safeTransferFrom(alice, bukWallet, 1, 1, data);
      supplierContract.safeBatchTransferFrom(alice, bukWallet, transferIds, transferAmts, data);
      assertEq(supplierContract.balanceOf(alice, 1), 0, "NFT didnot get transfered");
      vm.prank(bukWallet);
      // supplierContract.safeTransferFrom(bukWallet, alice, 1, 1, data);
      supplierContract.safeBatchTransferFrom(bukWallet, alice, transferIds, transferAmts, data);

      //To initiate refund when booking fails before confirming
      vm.prank(admin);
      factoryContract.bookingRefund(1, ids3, alice);
      checkBookingStatus(3, total[2], baseRate[2], BukTrips.BookingStatus.cancelled);

      //To Cancel Room
      vm.prank(admin);
      factoryContract.cancelRoom(1, 1, 6000000, 6000000,6000000);
      checkBookingStatus(1, total[0], baseRate[0], BukTrips.BookingStatus.cancelled);
      // assertEq(currency.balanceOf(address(treasury)), 0);

      //To Checkout Room
      vm.prank(admin);
      factoryContract.checkout(1, ids2);
      checkBookingStatus(2, total[1], baseRate[1], BukTrips.BookingStatus.expired);
      assertEq(supplierContract.uri(2), "");
      assertEq(utilityContract.uri(2), "token uri");

      //Set a new token uri for the NFT
      vm.prank(admin);
      factoryContract.setTokenUri(1, 2, "new token uri");

      //Set a new contract uri for the Contract
      vm.prank(admin);
      factoryContract.setContractUri(1, "new contract uri");

      assertEq(utilityContract.supplierContract(), address(supplierContract));
      //Set a new contract uri for the Contract
      vm.prank(admin);
      factoryContract.grantSupplierFactoryRole(1, address(0x5));
    }

    function checkBookingStatus(uint256 bookingId, uint256 total, uint256 baseRate, BukTrips.BookingStatus bookingStatus) public {(uint256 id, 
      BukTrips.BookingStatus status, 
      uint256 tokenID, 
      address owner,
      uint256 suppId,
      uint256 checkin,
      uint256 checkout,
      uint256 totalValue,
      uint256 baseRateValue) = factoryContract.bookingDetails(bookingId);
      assertEq(totalValue, total);
      assertEq(baseRateValue, baseRate);
      bool testStatus = (bookingStatus == status);
      assertTrue(testStatus);
    }

}
