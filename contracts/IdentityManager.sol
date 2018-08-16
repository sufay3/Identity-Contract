/**
 * @file IdentityManager.sol
 * @author sufay
 *
 * identity manager
 */

pragma solidity ^0.4.19;


import "./Identity.sol";


/*
 * @title IdentityManager
 * @dev a contract as an identity manager performing identity operating
 */
contract IdentityManager {
    mapping (address => Identity) public identityMap; // identity map storing all identity addresses
    uint public identityCount; // identity count

    address public admin; // contract administrator

    /**
     * @dev triggered when a new identity is created
     * @param _owner the identity owner
     * @param _identity the created identity address
     */
    event IdentityCreated(address indexed _owner, Identity indexed _identity);

    /**
     * @dev triggered when an identity is modified
     * @param _owner the identity owner
     * @param _identity the modified identity address
     */
    event IdentityChanged(address indexed _owner, Identity indexed _identity);

    /**
     * @dev triggered when an identity is deleted
     * @param _owner the identity owner
     * @param _identity the removed identity address
     */
    event IdentityRemoved(address indexed _owner, Identity indexed _identity);

    /**
     * @dev triggered when setting the validity of an identity
     * @param _owner the identity owner
     * @param _identity the destination identity
     */
    event IdentityValiditySet(address indexed _owner, Identity indexed _identity, bool indexed _validity);
    
    /**
     * @dev assert an address is valid, that is, it isn't equal to 0
     * @param addr address to be checked
     */
    modifier addressValid(address addr) {
        require(addr != address(0));
        _;
    }

    /**
     * @dev assert there exists no identity for the sender 
     */
    modifier noIdentity() {
        require(identityMap[msg.sender] == address(0));
        _;
    }

    /**
     * @dev assert there exists an identity for the sender 
     */
    modifier hasIdentity() {
        require(identityMap[msg.sender] != address(0));
        _;
    }

    /**
     * @dev assert there exists an identity for the specified address 
     */
    modifier hasIdentityByAddr(address addr) {
        require(identityMap[addr] != address(0));
        _;
    }

    /**
     * @dev assert the sender has the permission of the operation related to an identity
     * @param identity the identity to be operated
     */
    modifier hasIdentityPermission(Identity identity) {
        require(identityMap[msg.sender] == identity);
        _;
    }

    /**
     * @dev assert the given address has the permission of administration
     * @param addr the address to be checked
     */
    modifier hasAdminPermission(address addr) {
        require(addr == admin);
        _;
    }

    /**
     * @dev constructor
     */
    constructor() public {
        admin = msg.sender;
    }

    /**
     * @dev fallback is noop function
     */
    function() public {
        // noop
    }

    /** 
     * @dev create a new identity
     * @param _id identity id
     * @param _name name
     * @param _gender gender
     * @param _birthday birthday
     * @param _nationality nationality
     * @param _province province
     * @param _city city
     * @param _documentHashes the hashes of documents
     * @return true if successful
     */
    function createIdentity(
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
        noIdentity
        returns (bool)
    {
        // create a new Identity contract
        Identity identity = new Identity(msg.sender, _id, _name, _gender, _birthday, _nationality, _province, _city, _documentHashes);
        
        // add the identity to map
        identityMap[msg.sender] = identity;

        // increase the identity count
        identityCount++;

        // fire the created event
        emit IdentityCreated(msg.sender, identity);

        return true;
    }

    /** 
     * @dev modify all fileds of an identity
     * @param _id identity id
     * @param _name name
     * @param _gender gender
     * @param _birthday birthday
     * @param _nationality nationality
     * @param _province province
     * @param _city city
     * @param _documentHashes the hashes of documents
     * @return true if successful, otherwise false
     */
    function modifyIdentity(
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
        hasIdentity
        returns (bool)
    {
        // get the Identity contract
        Identity identity = identityMap[msg.sender];
        
        // modify the identity by call to the identity contract
        if(identity.modify(_id, _name, _gender, _birthday, _nationality, _province, _city, _documentHashes))
        {
            // fire the changed event
            emit IdentityChanged(msg.sender, identity);

            return true;
        }

        return false;
    }

    /**
     * @dev remove the identity of the sender
     * @return true if successful, otherwise false
     */
    function removeIdentity() public hasIdentity returns (bool) {
        // get the Identity contract
        Identity identity = identityMap[msg.sender];
        
        // delete the identity by call to the identity contract
        identity.remove();

        // change the identity map
        identityMap[msg.sender] = Identity(address(0));
            
        // decrease the identity count
        identityCount--;

        // fire the removed event
        emit IdentityRemoved(msg.sender, identity);

        return true;
    }

    /**
     * @dev set validity to an identity of the given owner
     * @param _owner the owner of the identity to be set
     * @param _validity validity to be assigned
     * @return true if successful
     */
    function setIdentityValidity(address _owner, bool _validity)
        public
        hasIdentityByAddr(_owner)
        hasAdminPermission(msg.sender)
        returns (bool)
    {
        // get the Identity
        Identity identity = identityMap[_owner];

        // set validity
        identity.setValidity(_validity);

        // fire the IdentityValiditySet event
        emit IdentityValiditySet(_owner, identity, _validity);

        return true;
    }

    /**
     * @dev get the identity data of the specified address
     * @param _owner the destination address
     * @return the identity data
     */
    function getIdentityData(address _owner) public view hasIdentityByAddr(_owner) 
        returns(
            address,
            bytes32,
            bytes32,
            uint8,
            bytes32,
            bytes32,
            bytes32,
            bytes32,
            bytes32[],
            bool
        )
    {
        // get the Identity contract
        Identity identity = identityMap[_owner];

        // get the identity data
        return identity.getIdentity();
    }

    /**
     * @dev get the address of the identity of the given owner
     * @param _owner the owner whose identity address is to be retrieved
     */
    function getIdentityAddress(address _owner) public view returns (address) {
        return identityMap[_owner];
    }

    /**
     * @dev check if an address has an identity contract
     * @param _address the address to be checked
     * @return true if existing, otherwise false
     */
    function identityExists(address _address) public view returns (bool) {
        if (identityMap[_address] != address(0)) {
            return true;
        }

        return false;
    }

    /**
     * @dev check if an identity is valid
     * @param _owner the owner of the identity to be checked
     * @return true if valid, otherwise false
     */
    function identityValid(address _owner) public view hasIdentityByAddr(_owner) returns (bool) {
        // get the Identity contract
        Identity identity = identityMap[_owner];

        // call Identity
        return identity.validated();
    }

    /**
     * @dev get the identity count
     * @return the identity count
     */
    function getIdentityCount() public view returns (uint) {
        return identityCount;
    }
}
