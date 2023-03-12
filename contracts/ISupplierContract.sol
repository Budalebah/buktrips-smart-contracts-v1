// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

interface ISupplierContract {

    function updateSupplierDetails(bytes32 name, string memory contractName) external;

    function grantFactoryRole(address _factory_contract) external;

    function toggleNFTStatus(uint _id, bool status) external;

    function uri(uint256 id) external view returns (string memory);

    function mint(uint256 _id, address account, uint256 amount, bytes calldata data, string calldata _uri, bool _status) external returns (uint256);

    function burn(address account, uint256 id, uint256 amount, bool utility) external;

    function setContractURI(string memory _contractUri) external;

    function setURI(uint256 _id, string memory _newuri) external;

}
