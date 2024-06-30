// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VehicleManagement {
    address public owner;
    uint64 public vehicleCount = 0;

    struct Vehicle {
        uint256 vehicleId;
        uint64 phoneNum;
        string buyDate;
        string model;
        string plateNum;
        string insuranceValidity;
        string pollutionValidity;
    }

    mapping(address => Vehicle[]) public userVehicles;
    mapping(uint256 => Vehicle) public allVehicles;

    event VehicleAdded(address indexed user, uint256 vehicleId, uint64 phoneNum, string buyDate, string model, string plateNum, string insuranceValidity, string pollutionValidity);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function parseAndConvert(string memory input) public pure returns (uint256) {
        uint256 result;
        for (uint256 i = 0; i < bytes(input).length; i++) {
            result = result * 10 + (uint8(bytes(input)[i]) - 48);
        }
        return result;
    }

    function addVehicle(
        string memory _vehicleId,
        uint64 phoneNum,
        string memory buyDate,
        string memory model,
        string memory plateNum,
        string memory insuranceValidity,
        string memory pollutionValidity
    ) public {
        vehicleCount += 1;
        uint256 vehicleId = parseAndConvert(_vehicleId);
        Vehicle memory newVehicle = Vehicle({
            vehicleId: vehicleId,
            phoneNum: phoneNum,
            buyDate: buyDate,
            model: model,
            plateNum: plateNum,
            insuranceValidity: insuranceValidity,
            pollutionValidity: pollutionValidity
        });

        userVehicles[msg.sender].push(newVehicle);
        allVehicles[vehicleId] = newVehicle;

        emit VehicleAdded(msg.sender, vehicleId, phoneNum, buyDate, model, plateNum, insuranceValidity, pollutionValidity);
    }

    function getUserVehicles(address _userAddress) external view returns (Vehicle[] memory) {
        return userVehicles[_userAddress];
    }

    function getVehicleDetails(uint256 _vehicleId) external view returns (Vehicle memory) {
        return allVehicles[_vehicleId];
    }
}
