// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

interface IBukSupplierUtilityDeployer {
    function deploySupplierUtility(string memory _contractName, uint256 id, bytes32 _name, string memory _contractUri) external returns (address);
}
