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

    modifier onlyRenter(uint256 _assetId) {
        require(msg.sender == assets[_assetId].renter, "Not asset renter");
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

    // 🔁 Extend rental by additional days
    function extendRental(uint256 _assetId, uint256 _additionalDays) public payable onlyRenter(_assetId) {
        Asset storage asset = assets[_assetId];
        require(block.timestamp < asset.rentedUntil, "Rental period over");

        uint256 additionalRent = asset.rentPerDay * _additionalDays;
        require(msg.value >= additionalRent, "Insufficient payment");

        asset.rentedUntil += _additionalDays * 1 days;
    }

    // 🔓 End rental early (by renter or owner)
    function endRental(uint256 _assetId) public {
        Asset storage asset = assets[_assetId];
        require(msg.sender == asset.renter || msg.sender == owner, "Not authorized");

        asset.renter = address(0);
        asset.rentedUntil = 0;
    }

    // 🧾 Withdraw collected funds
    function withdrawFunds() public onlyOwner {
        payable(owner).transfer(address(this).balance);
    }

    // 👥 Joint rental (two users split the rent)
    function jointRentAsset(uint256 _assetId, uint256 _days, address _partner) public payable {
        Asset storage asset = assets[_assetId];
        require(asset.renter == address(0) || block.timestamp > asset.rentedUntil, "Asset currently rented");

        uint256 totalRent = asset.rentPerDay * _days;
        require(msg.value >= totalRent, "Insufficient payment");

        // Combine the msg.sender and partner into a "joint renter" logic (simple version)
        require(_partner != address(0) && _partner != msg.sender, "Invalid partner");

        asset.renter = address(uint160(uint256(keccak256(abi.encodePacked(msg.sender, _partner, block.timestamp)))));
        asset.rentedUntil = block.timestamp + (_days * 1 days);
    }

    function getAsset(uint256 _assetId) public view returns (string memory, uint256, address, uint256) {
        Asset memory asset = assets[_assetId];
        return (asset.name, asset.rentPerDay, asset.renter, asset.rentedUntil);
    }
}
