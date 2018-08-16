/**
 * @file Identity.sol
 * @author sufay
 *
 * Identity contract
 */

pragma solidity ^0.4.19;


/**
 * @title Identity
 * @dev a contract representing an identity
 */
contract Identity {
    // identity data
    address public owner; // the owner of the identity
    bytes32 public id;
    bytes32 public name;
    uint8 public gender;
    bytes32 public birthday;
    bytes32 public nationality;
    bytes32 public province;
    bytes32 public city;
    bytes32[] public documentHashes; // the hashes of the variety of documents
    bool public valid; // validity

    // identity manager
    address public manager;

    // modification count
    uint8 public modificationCount;
    // max modification num
    uint8 constant MAX_MODIFICATION_NUM = 50;

    /**
     * @dev assert the sender is the owner
     */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    /**
     * @dev assert the sender is the manager
     */
    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    /**
     * @dev assert an address is valid, that is, it isn't equal to 0
     * @param addr address to be checked
     */
    modifier addressValid(address addr) {
        require(addr != address(0));
        _;
    }

    /**
     * @dev assert the modification count doesn't exceed the limit
     */
    modifier modifiable() {
        require(modificationCount < MAX_MODIFICATION_NUM);
        _;
    }

    /** 
     * @dev constructor
     * @param _owner identity owner
     * @param _id id
     * @param _name name
     * @param _gender gender
     * @param _birthday birthday
     * @param _nationality nationality
     * @param _province province
     * @param _city city
     * @param _documentHashes the hashes of documents
     */
    constructor(
        address _owner,
        bytes32 _id,
        bytes32 _name,
        uint8 _gender,
        bytes32 _birthday,
        bytes32 _nationality,
        bytes32 _province,
        bytes32 _city,
        bytes32[] _documentHashes
    )
        public
    {
        // set the identity data
        set(_owner, _id, _name, _gender, _birthday, _nationality, _province, _city, _documentHashes);
    
        // set the manager
        manager = msg.sender;
    }

    /**
     * @dev fallback is noop function
     */
    function() public {
        // noop
    }

    /** 
     * @dev modify the identity data
     * @param _id id
     * @param _name name
     * @param _gender gender
     * @param _birthday birthday
     * @param _nationality nationality
     * @param _province province
     * @param _city city
     * @param _documentHashes the hashes of documents
     * @return true if successful
     */
    function modify(
        bytes32 _id,
        bytes32 _name,
        uint8 _gender,
        bytes32 _birthday,
        bytes32 _nationality,
        bytes32 _province,
        bytes32 _city,
        bytes32[] _documentHashes
    )
        public
        onlyManager
        modifiable
        returns (bool)
    {
        // increase the modificaton count
        modificationCount++;

        // set the identity data
        set(owner, _id, _name, _gender, _birthday, _nationality, _province, _city, _documentHashes);
        
        return true;
    }
    
    /**
     * @dev remove the identity
     * @return true if successful
     */
    function remove() public onlyManager {
        selfdestruct(owner);
    }
    
    /** 
     * @dev set the identity data
     * @param _owner identity owner
     * @param _id id
     * @param _name name
     * @param _gender gender
     * @param _birthday birthday
     * @param _nationality nationality
     * @param _province province
     * @param _city city
     * @param _documentHashes the hashes of documents
     */
    function set(
        address _owner,
        bytes32 _id,
        bytes32 _name,
        uint8 _gender,
        bytes32 _birthday,
        bytes32 _nationality,
        bytes32 _province,
        bytes32 _city,
        bytes32[] _documentHashes
    )
        internal
        addressValid(_owner)
    {
        owner = _owner;
        id = _id;
        name = _name;
        gender = _gender;
        birthday = _birthday;
        nationality = _nationality;
        province = _province;
        city = _city;
        documentHashes = _documentHashes;
    }

    /**
     * @dev set the validity of the identity
     * @param _validity validity to be set
     */
    function setValidity(bool _validity) external onlyManager {
        valid = _validity;
    }

    /**
     * @dev get the identity data
     * @return identity data
     */
    function getIdentity() public view returns (address, bytes32, bytes32, uint8, bytes32, bytes32, bytes32, bytes32, bytes32[], bool) {
        return (owner, id, name, gender, birthday, nationality, province, city, documentHashes, valid);
    }

    /**
     * @dev get the owner
     * @return the owner
     */
    function getOwner() public view returns (address) {
        return owner;
    }

    /**
     * @dev get the validity
     * @return validity
     */
    function validated() public view returns (bool) {
        return valid;
    }
}
