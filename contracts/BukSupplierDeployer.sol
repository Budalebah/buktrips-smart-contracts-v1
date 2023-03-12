// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";
import "./SupplierContract.sol";

/**
 *@author BUK Technology Inc 
 *@title BUK Protocol Supplier Deployer Contract
 *@dev Contract to deploy instances of the SupplierContract contract
*/
contract BukSupplierDeployer is Context {

    /**
    * @dev Address of the contract's admin
    */
    address private admin;
    /**
    * @dev Address of the factory contract
    */
    address private factoryContract;

    /**
    * @dev Event emitted when a new Supplier contract is deployed
    * @param id ID of the deployed supplier
    * @param supplierContract Address of the deployed supplier contract
    */
    event SupplierDeploy(uint256 indexed id, address indexed supplierContract);
    /**
    * @dev Event emitted when the factory contract is updated
    * @param deployerContract Address of the deployer contract
    * @param factoryContract Address of the updated factory contract
    */
    event DeployerFactoryUpdated(address indexed deployerContract, address indexed factoryContract);

    /**
    @dev Modifier to allow access only to the factory contract
    @param addr Address to verify
    */
    modifier onlyAdmin(address addr) {
        require(addr == admin, "Only Admin contract has the access");
        _;
    }
    /**
    * @dev Modifier to allow access only to the admin
    * @param addr Address to verify
    */
    modifier onlyFactory(address addr) {
        require(addr == factoryContract, "Only Factory contract has the access");
        _;
    }

    /**
    * @dev Contract constructor, sets the factory contract address
    * @param _factoryContract Address of the factory contract
    */
    constructor( address _factoryContract ) {
        factoryContract = _factoryContract;
        admin = _msgSender();
    }

    /**
    * @dev Function to update the factory contract address
    * @param _factoryContract Address of the updated factory contract
    * @notice This function can only be called by admin
    */
    function updateFactory(address _factoryContract) external onlyAdmin(_msgSender()) {
        factoryContract = _factoryContract;
        emit DeployerFactoryUpdated(address(this), factoryContract);
    }

    /**
    * @dev Function to deploy a new instance of the Supplier contract
    * @param id ID of the new supplier
    * @param _name Name of the new supplier
    * @param _supplierOwner Address of the owner of the new supplier
    * @param _utilityContractAddr Address of the utility contract for the new supplier
    * @param _contractUri URI of the new supplier contract
    * @return Address of the deployed Supplier contract
    * @notice This function can only be called by factory contract
    */
    function deploySupplier(string memory _contractName, uint256 id, bytes32 _name, address _supplierOwner, address _utilityContractAddr, string memory _contractUri) external onlyFactory(_msgSender()) returns (address) {
        SupplierContract supplier;
        supplier = new SupplierContract(_contractName, id, _name, _supplierOwner, _utilityContractAddr, factoryContract, _contractUri);
        emit SupplierDeploy(id, address(supplier));
        return address(supplier);
    }
}
