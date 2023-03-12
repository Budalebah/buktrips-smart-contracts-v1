// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "@openzeppelin/contracts/utils/Context.sol";
import "./SupplierUtilityContract.sol";

/**
* @author BUK Technology Inc
* @title BUK Protocol Supplier Utility Deployer Contract
* @dev Contract to deploy instances of the SupplierContractUtility contract
*/
contract BukSupplierUtilityDeployer is Context {

    /**
    * @dev Address of the contract's admin
    */
    address private admin;
    /**
    * @dev Address of the factory contract
    */
    address private factoryContract;

    /**
    * @dev Event emitted when a new Supplier contract utility is deployed
    * @param id ID of the deployed supplier utility
    * @param supplierUtilityContract Address of the deployed supplier contract utility
    */
    event SupplierUtilityDeploy(uint256 indexed id, address indexed supplierUtilityContract);
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
    * @dev Function to deploy a new instance of the Supplier contract utility
    * @param id ID of the new supplier utility
    * @param _name Name of the new supplier utility
    * @param _contractUri URI of the new supplier contract utility
    * @return Address of the deployed Supplier contract utility
    * @notice This function can only be called by factory contract
    */
    function deploySupplierUtility(string memory _contractName, uint256 id, bytes32 _name, string memory _contractUri) external onlyFactory(_msgSender()) returns (address) {
        SupplierUtilityContract supplier;
        supplier = new SupplierUtilityContract(_contractName, id, _name, factoryContract, _contractUri);
        emit SupplierUtilityDeploy(id, address(supplier));
        return address(supplier);
    }
}
