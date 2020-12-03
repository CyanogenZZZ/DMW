pragma solidity 0.5.17;

import "./ERC721Full.sol";
import "./Ownable.sol";

//NFT Contract


contract Defimon is ERC721Full, Ownable {
    // All 80 Defimon got color Purple, Blue and Red
    mapping(uint256 => string) public colorDefimon;

    // Only gameAddress can burn Defimon
    address public gameControllerAddress;
    // Only farming can mint Defimon
    address public farmControllerAddress;

    constructor() public ERC721Full("DefimonToken") {
        // Defimon Colors init

        // id 1 to 10 (10 Defimon) are "Purple Defimon"
        for (uint256 i = 1; i < 11; i++) {
            colorDefimon[i] = "Purple";
        }

        // id 11 to 60 (50 Defimon) are "Blue Defimon"
        for (uint256 i = 11; i < 61; i++) {
            colorDefimon[i] = "Blue";
        }

        // id 61 to 160 (100 Defimon) are "Red Defimon"
        for (uint256 i = 61; i < 161; i++) {
            colorDefimon[i] = "Red";
        }
    }

    modifier onlyGameController() {
        require(msg.sender == gameControllerAddress);
        _;
    }
    
    modifier onlyFarmingController() {
        require(msg.sender == farmControllerAddress);
        _;
    }

    // events for prevent Players from any change
    event GameAddressChanged(address newGameAddress);
    
    // events for prevent Players from any change
    event FarmAddressChanged(address newFarmAddress);
    

    // init game smart contract address
    function setGameAddress(address _gameAddress) public onlyOwner() {
        gameControllerAddress = _gameAddress;
        emit GameAddressChanged(_gameAddress);
    }
    
        // init farming smart contract address
    function setFarmingAddress(address _farmAddress) public onlyOwner() {
        farmControllerAddress = _farmAddress;
        emit FarmAddressChanged(_farmAddress);
    }

    // Function that only farming smart contract address can call for mint a Defimon
    function mintDefimon(address _to, uint256 _id) public onlyFarmingController() {
        _mint(_to, _id);
    }

    // Function that only game smart contract address can call for burn Defimon trilogy
    // Defimon must be approvedForAll by the owner for contract of gameAddress
    function burnDefimonTrilogy(
        address _ownerOfDefimon,
        uint256 _id1,
        uint256 _id2,
        uint256 _id3
    ) public onlyGameController() {
        require(
            keccak256(abi.encodePacked(colorDefimon[_id1])) ==
                keccak256(abi.encodePacked("Purple")) &&
                keccak256(abi.encodePacked(colorDefimon[_id2])) ==
                keccak256(abi.encodePacked("Blue")) &&
                keccak256(abi.encodePacked(colorDefimon[_id3])) ==
                keccak256(abi.encodePacked("Red"))
        );
        _burn(_ownerOfDefimon, _id1);
        _burn(_ownerOfDefimon, _id2);
        _burn(_ownerOfDefimon, _id3);
    }
}
