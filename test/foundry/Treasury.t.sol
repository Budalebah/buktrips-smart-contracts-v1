// SPDX-License-Identifier: UNLICENSED
pragma solidity =0.8.13;

import "forge-std/Test.sol";
import 'contracts/Treasury.sol';
import '../SampleCurrency.sol';

contract TreasuryTest is Test {
    address factoryContract = address(0x1);
    address admin = address(0x3);
    Currency currency;
    Currency newCurrency;
    Treasury treasury;
    address alice = address(0x9);
    address bob = address(0x7);

    function setUp() public {
      //Deploy ERC20 
      vm.prank(admin);
      currency = new Currency();

      //Deploy ERC20 
      vm.prank(admin);
      newCurrency = new Currency();

      //Mint ERC20 to Alice's wallet
      vm.prank(admin);
      newCurrency.mint(alice, 10000000000);

      //Deploy Treasury
      vm.prank(admin);
      treasury = new Treasury(address(currency));

      //To Set Factory contract in Treasury
      vm.prank(admin);
      treasury.setFactory(factoryContract);

      //Mint ERC20 to Treasury Contract
      vm.prank(admin);
      currency.mint(address(treasury), 100000000000);

      //Mint ERC20 to Alice's wallet
      vm.prank(admin);
      newCurrency.mint(alice, 10000000000);

      //Mint ERC20 to Treasury Contract
      vm.prank(admin);
      newCurrency.mint(address(treasury), 10000000000);
    }

    function testSetCurrency() public {
      vm.prank(admin);
      treasury.setCurrency(address(newCurrency));
      assertEq(address(newCurrency), treasury.currency());
    }

    function testSetFactory() public {
      vm.prank(admin);
      treasury.setFactory(address(0x8));
      assertEq(address(0x8), treasury.factoryContract());
    }

    function testWithdrawUSDCFund() public {
      vm.prank(admin);
      treasury.withdrawUSDCFund(100000000, admin);
      assertEq(currency.balanceOf(admin), 100000000);
    }

    function testWithdrawFund() public {
      vm.prank(admin);
      treasury.withdrawFund(100000000, admin, address(newCurrency));
      assertEq(newCurrency.balanceOf(admin), 100000000);
    }

    function testCancelUSDCRefund() public {
      vm.prank(factoryContract);
      treasury.cancelUSDCRefund(100000000, bob);
      assertEq(currency.balanceOf(bob), 100000000);
    }

    function testCancelRefund() public {
      vm.prank(factoryContract);
      treasury.cancelRefund(100000000, bob, address(newCurrency));
      assertEq(newCurrency.balanceOf(bob), 100000000);
    }
}
