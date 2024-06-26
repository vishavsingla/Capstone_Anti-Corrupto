
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract LandRegistery {
    address public owner;
    uint256 landCount = 0;

    enum LandStatus { NotRegistered, Registered, Transferred }

    enum LandType { Government, Commercial, Agricultural, Industrial, Residential }

    struct Land {
        uint256 landId;
        address prevOwner;
        address currentOwner;
        string location;
        string area;
        string dimensionOfLand;
        string landIdentificationNumber;
        LandStatus status;
        LandType landType;
        string transferAmount; // Added field to store the transfer amount
    }

    mapping(address => Land[]) public userLands;
    mapping(uint256 => Land) public allLands;

    event LandRegistered(uint256 indexed landId, address indexed owner, string location, string area, string dimensionOfLand, string landIdentificationNumber, LandType landType);
    event LandTransferred(uint256 indexed landId, address indexed from, address indexed to, string transferAmount); // Modified event to include transferAmount

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // modifier landExists(uint256 _landId) {
    //     require(_landId > 0 && _landId <= landCount, "Land does not exist");
    //     _;
    // }

    constructor() {
        owner = msg.sender;
    }

    function parseAndConvert(string memory input) public pure returns (uint256) {
        uint256 result;
        assembly {
            result := mload(add(input, 32))
        }
        return result;
    }

    function registerLand(
        string memory _location,
        string memory _area,
        string memory _dimensionOfLand,
        string memory _landIdentificationNumber,
        LandType _landType
    ) external {
        landCount++;
        uint256 landId = parseAndConvert(_landIdentificationNumber);
        Land memory newLand = Land({
            landId: landId,
            prevOwner: address(0),
            currentOwner: msg.sender,
            location: _location,
            area: _area,
            dimensionOfLand: _dimensionOfLand,
            landIdentificationNumber: _landIdentificationNumber,
            status: LandStatus.Registered,
            landType: _landType,
            transferAmount: "0" 
        });

        userLands[msg.sender].push(newLand);
        allLands[landId] = newLand;

        emit LandRegistered(landId, msg.sender, _location, _area, _dimensionOfLand, _landIdentificationNumber, _landType);
    }

    function transferLand(string memory _landIdentificationNumber, address _newOwner, string memory _transferAmount) external {
        require(_newOwner != address(0), "Invalid new owner address");
        uint256 _landId = parseAndConvert(_landIdentificationNumber);
        Land storage land = allLands[_landId];
        require(land.currentOwner == msg.sender, "Only the current owner can transfer the land");
        // require(land.status == LandStatus.Registered, "Land is not registered");

        land.prevOwner = land.currentOwner;
        land.currentOwner = _newOwner;
        land.status = LandStatus.Transferred;
        land.transferAmount = _transferAmount;

        userLands[msg.sender].push(land);
        userLands[_newOwner].push(land);

        emit LandTransferred(_landId, msg.sender, _newOwner, _transferAmount);
    }

    function getUserLands(address _userAddress) external view returns (Land[] memory) {
        return userLands[_userAddress];
    }

    function getLandDetails(uint256 _landId) external view returns (Land memory) {
        return allLands[_landId];
    }
}
