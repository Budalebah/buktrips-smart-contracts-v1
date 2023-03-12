// SPDX-License-Identifier: MIT
pragma solidity =0.8.13;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./ISupplierContractUtility.sol";

/**
* @title BUK Protocol Supplier Contract
* @author BUK Technology Inc
* @dev Contract for managing hotel room-night inventory supplier data and ERC1155 token management for room-night NFTs
*/
contract SupplierContract is AccessControl, ERC1155 {

    /**
    * @dev name of the supplier contract
    */
    string public name;
    /**
    * @dev address of the supplier contract
    */
    address private utilityContract;
    /**
    * @dev Contract URI string
    */
    string private contractUri;

    /**
    * @dev Struct for supplier data
    * @var id Supplier ID
    * @var name Supplier name
    */
    struct SupplierData {
        uint256 id;
        bytes32 name;
    }

    /**
    * @dev Supplier data instance
    */
    SupplierData public details;


    /**
    * @dev Mapping for token URI's for booked tickets
    */
    mapping(uint256 => string) public bookingTickets; //tokenID -> uri
    /**
    * @dev Mapping for token transferability status
    */
    mapping(uint256 => bool) public transferable; //tokenID -> uri

    /**
    * @dev Constant for the role of the supplier owner
    */
    bytes32 public constant SUPPLIER_OWNER_ROLE = keccak256("SUPPLIER_OWNER");
    /**
    * @dev Constant for the role of the factory contract
    */
    bytes32 public constant FACTORY_CONTRACT_ROLE = keccak256("FACTORY_CONTRACT");
    /**
    * @dev Constant for the role of both factory and supplier to update the contract
    */
    bytes32 public constant UPDATE_CONTRACT_ROLE = keccak256("UPDATE_CONTRACT"); // Both Factory and Supplier


    /**
    * @dev Event to set the contract URI
    */
    event SetContractURI(string indexed contractUri);
    /**
    * @dev Event to update the supplier details
    */
    event UpdateSupplierDetails(bytes32 indexed name, string indexed contractName);
    /**
    * @dev Event to safe transfer NFT
    */
    event GrantFactoryRole(address indexed oldFactory, address indexed newFactory);
    /**
    * @dev Event to set token URI
    */
    event SetURI(uint256 indexed id, string indexed uri);
    /**
    * @dev Event to toggle NFT status
    */
    event ToggleNFT(uint256 indexed _id, bool indexed status);

    /**
    * @dev Constructor to initialize the contract
    * @param _id Supplier ID
    * @param _name Supplier name
    * @param _supplierOwner Address of the supplier owner
    * @param _utilityContract Address of the utility contract
    * @param _factoryContract Address of the factory contract
    * @param _contractUri Contract URI string
    */
    constructor(string memory _contractName, uint256 _id, bytes32 _name, address _supplierOwner, address _utilityContract, address _factoryContract, string memory _contractUri) ERC1155("") {
        details.id = _id;
        details.name = _name;
        name = _contractName;
        _setRoleAdmin(FACTORY_CONTRACT_ROLE, FACTORY_CONTRACT_ROLE);
        _setRoleAdmin(UPDATE_CONTRACT_ROLE, FACTORY_CONTRACT_ROLE);
        _grantRole(FACTORY_CONTRACT_ROLE, _factoryContract);
        _grantRole(UPDATE_CONTRACT_ROLE, _factoryContract);
        _grantRole(SUPPLIER_OWNER_ROLE, _supplierOwner);
        _grantRole(UPDATE_CONTRACT_ROLE, _supplierOwner);
        utilityContract = _utilityContract;
        contractUri = _contractUri;
    }

    /**
    * @dev Set the contract URI of the supplier contract.
    * @param _contractUri - The URI to be set.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function setContractURI(string memory _contractUri) external onlyRole(FACTORY_CONTRACT_ROLE) {
        contractUri = _contractUri;
        ISupplierContractUtility(utilityContract).setContractURI(_contractUri);
        emit SetContractURI(contractUri);
    }
    
    /**
    * @dev To set the factory role.
    * @param _factoryContract - Address of factory contract
    */
    function grantFactoryRole(address _factoryContract) external onlyRole(FACTORY_CONTRACT_ROLE) {
        ISupplierContractUtility(utilityContract).grantFactoryRole(_factoryContract);
        _grantRole(UPDATE_CONTRACT_ROLE, _factoryContract);
        _grantRole(FACTORY_CONTRACT_ROLE, _factoryContract);
        revokeRole(UPDATE_CONTRACT_ROLE, _msgSender());
        revokeRole(FACTORY_CONTRACT_ROLE, _msgSender());
        emit GrantFactoryRole(_msgSender(), _factoryContract);
    }

    /**
    * @dev Update the details of the supplier.
    * @param _name - The new name of the supplier.
    * @notice This function can only be called by addresses with `UPDATE_CONTRACT_ROLE`
    */
    function updateSupplierDetails(bytes32 _name, string memory _contractName) external onlyRole(UPDATE_CONTRACT_ROLE) {
        details.name = _name;
        name = _contractName;
        ISupplierContractUtility(utilityContract).updateSupplierDetails(_name, _contractName);
        emit UpdateSupplierDetails(_name, _contractName);
    }

    /**
    * @dev Sets the URI for a specific token ID.
    * @param _id - The ID of the token.
    * @param _newuri - The new URI for the token.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function setURI(uint256 _id, string memory _newuri) external onlyRole(FACTORY_CONTRACT_ROLE) {
        _setURI(_id,_newuri);
        ISupplierContractUtility(utilityContract).setURI(_id,_newuri);
        emit SetURI(_id,_newuri);
    }

    /**
    * @dev Toggle the transferable status of the NFT.
    * @param _id - The token ID to toggle the transferable status for.
    * @param _status - The new transferable status for the NFT.
    */
    function toggleNFTStatus(uint256 _id, bool _status) external onlyRole(FACTORY_CONTRACT_ROLE) {
        transferable[_id] = _status;
        emit ToggleNFT(_id,_status);
    }

    /**
    * @dev Mint a new NFT with a specific token ID, account, amount, and data.
    * @param _id - The token ID to mint the NFT with.
    * @param account - The account to mint the NFT to.
    * @param amount - The amount of NFTs to mint.
    * @param data - The data to store with the NFT.
    * @param _uri - The URI to associate with the NFT.
    * @param _status - The transferable status for the NFT.
    * @return uint256 - The token ID of the newly minted NFT.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function mint(uint256 _id, address account, uint256 amount, bytes calldata data, string calldata _uri, bool _status) external onlyRole(FACTORY_CONTRACT_ROLE) returns (uint256) {
        transferable[_id] = _status;
        _mint(account, _id, amount, data);
        _setURI( _id, _uri);
        return ( _id );
    }

    /**
    * @dev Burn a specific NFT.
    * @param account - The account to burn the NFT from.
    * @param id - The token ID of the NFT to burn.
    * @param amount - The amount of NFTs to burn.
    * @param utility - Whether or not to call the utility contract to burn the NFT.
    * @notice This function can only be called by a contract with `FACTORY_CONTRACT_ROLE`
    */
    function burn(address account, uint256 id, uint256 amount, bool utility) external onlyRole(FACTORY_CONTRACT_ROLE) {
        string memory uri_ =  bookingTickets[id];
        bookingTickets[id] = "";
        if(utility) {
            ISupplierContractUtility(utilityContract).mint(account, id, amount, uri_, "");
        }
        _burn(account, id, amount);
    }
    
    /**
    * @dev Returns the contract URI of the supplier contract.
    * @return contractUri - The URI of the supplier contract.
    */
    function contractURI() public view returns (string memory) {
        return contractUri;
    }

    /**
    * @dev Returns the URI associated with the token ID.
    * @param _id - The token ID to retrieve the URI for.
    * @return string - The URI associated with the token ID.
    */
    function uri(uint256 _id) public view virtual override returns (string memory) {
        return bookingTickets[_id];
    }

    /**
    * @dev Transfers ownership of an NFT token from one address to another.
    * @param from - The current owner of the NFT.
    * @param to - The address to transfer the ownership to.
    * @param id - The ID of the NFT token.
    * @param data - Additional data to include in the transfer.
    */
    function safeTransferFrom(address from, address to, uint256 id, uint256 amount, bytes memory data) public virtual override {
        require(transferable[id], "This NFT is non transferable");
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "ERC1155: caller has no access");
        super._safeTransferFrom(from, to, id, amount, data);
    }

    /**
    * @dev Transfers ownership of multiple NFT tokens from one address to another.
    * @param from - The current owner of the NFTs.
    * @param to - The address to transfer the ownership to.
    * @param ids - The IDs of the NFT tokens.
    * @param data - Additional data to include in the transfer.
    */
    function safeBatchTransferFrom(address from, address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) public virtual override {
        require((ids.length < 11), "Exceeds max room booking limit");
        uint256 len = ids.length;
        for(uint i=0; i<len; ++i) {
            require(transferable[ids[i]], "One of the NFTs is non-transferable");
        }
        require(from == _msgSender() || isApprovedForAll(from, _msgSender()), "ERC1155: caller has no access");
        super._safeBatchTransferFrom(from, to, ids, amounts, data);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view override(AccessControl, ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    } 

    function _setURI(uint256 id, string memory newuri) internal {
        bookingTickets[id] = newuri;
    }
}
