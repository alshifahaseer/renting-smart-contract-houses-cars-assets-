// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Renting {
    address public owner;

    struct Asset {
        string name;
        uint256 rentPerDay;
        address renter;
        uint256 rentedUntil;
    }

    mapping(uint256 => Asset) public assets;
    uint256 public assetCount;

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Not contract owner");
        _;
    }

    function addAsset(string memory _name, uint256 _rentPerDay) public onlyOwner {
        assets[assetCount] = Asset(_name, _rentPerDay, address(0), 0);
        assetCount++;
    }

    function rentAsset(uint256 _assetId, uint256 _days) public payable {
        Asset storage asset = assets[_assetId];
        require(asset.renter == address(0) || block.timestamp > asset.rentedUntil, "Asset currently rented");
        uint256 totalRent = asset.rentPerDay * _days;
        require(msg.value >= totalRent, "Insufficient payment");

        asset.renter = msg.sender;
        asset.rentedUntil = block.timestamp + (_days * 1 days);
    }

    function getAsset(uint256 _assetId) public view returns (string memory, uint256, address, uint256) {
        Asset memory asset = assets[_assetId];
        return (asset.name, asset.rentPerDay, asset.renter, asset.rentedUntil);
    }
}

