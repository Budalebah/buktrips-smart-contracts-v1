// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

interface ISupplierContractUtility {

    function grantSupplierRole(address _supplierContract) external;

    function grantFactoryRole(address _factoryContract) external;

    function updateSupplierDetails(bytes32 _name, string memory _contractName) external;

    function mint(address account, uint256 _id, uint256 amount, string calldata _newuri, bytes calldata data) external;

    function setURI(uint256 _id, string memory _newuri) external;

    function setContractURI(string memory _contractUri) external;
}
