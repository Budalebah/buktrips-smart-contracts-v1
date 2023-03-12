// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

interface IBukSupplierDeployer {
    function deploySupplier(string memory _contractName, uint256 id, bytes32 _name, address _supplierOwner, address _utilityContractAddr, string memory _contractUri) external returns (address);
}
