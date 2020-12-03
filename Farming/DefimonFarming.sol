pragma solidity 0.5.17;

import "./Ownable.sol";
import "./Defimon.sol";
import "./DefimonWorldToken.sol";
import "./SafeMath.sol";

contract DefimonFarming is Ownable {
    
    using SafeMath for uint256;
    
    // Tokens used in the farming
    Defimon public Defimon;
    DefimonWorldToken public Defimon;
    
    constructor(Defimon _Defimon, DefimonWorldToken _DefimonWorldToken) public{
        //init Defimon token address
        setDefimonToken(_Defimon);
        setDefimonWorldToken(_DefimonWorldToken);
    }
    
    // Defimon farming variable
    mapping(uint256 => bool) public canBeFarmed;
    mapping(uint256 => bool) public farmed;
    // Defimon who is farming
    mapping(uint256 => bool) public onFarming;
    // address who farm the Defimon
    mapping(uint256 => address) private _farmingBy;
    
    // array of spots for Defimon can be farmed
    uint256[] private _spots;
    
    // Number of DMW Locked on stacking
    uint256 public DMWStackedOnFarming;
    
    // Time for farming
    uint256 public PurpleDefimonFarmingTime = 60 days;
    uint256 public BlueDefimonFarmingTime = 40 days;
    uint256 public redDefimonFarmingTime = 20 days;
    
    // Amount for farming Values will and can change 
    uint256 public amountForPurpleDefimon = 4500; 
    uint256 public amountForBlueDefimon = 4000;
    uint256 public amountForRedDefimon = 1500;
 
    
    // =========================================================================================
    // Setting Tokens Functions
    // =========================================================================================

    
    // Set the DefimonToken address
    function setDefimonToken(Defimon _Defimon) public onlyOwner() {
        Defimon = _Defimon;
    }
    
    // Set the DefimonWorldToken address
    function setDefimonWorldToken(DefimonWorldToken _DefimonWorldToken) public onlyOwner() {
        Defimon = _DefimonWorldToken;
    }
    
    
    // =========================================================================================
    // Setting Farming conditions
    // =========================================================================================


    //functions for setting time needed for farming a Defimon
    function setFarmingTimePurpleDefimon(uint256 _time) public onlyOwner(){
        PurpleDefimonFarmingTime = _time;
    }
    
    function setFarmingTimeBlueDefimon(uint256 _time) public onlyOwner(){
        blueDefimonFarmingTime = _time;
    }
    
    function setFarmingTimeRedDefimon(uint256 _time) public onlyOwner(){
        redDefimonFarmingTime = _time;
    }
    
    //setting amount DMW needed for farming a Defimon
    function setAmountForFarmingPurpleDefimon(uint256 _amount) public onlyOwner(){
        amountForPurpleDefimon = _amount;
    }
    
    function setAmountForFarmingBlueDefimon(uint256 _amount) public onlyOwner(){
        amountForBlueDefimon = _amount;
    }
    
    function setAmountForFarmingRedDefimon(uint256 _amount) public onlyOwner(){
        amountForRedDefimon = _amount;
    }
    
    // =========================================================================================
    // Setting Defimon ID can be farmed
    // =========================================================================================

    // Create a spot for a Defimon who can be farmed
    function setDefimonIdCanBeFarmed(uint256 _id) public onlyOwner(){
        require(_id>=1 && _id<=160);
        require(farmed[_id] == false,"Already farmed");
        canBeFarmed[_id] = true;
        _spots.push(_id);
    }
    
    // =========================================================================================
    // Farming
    // =========================================================================================

    struct farmingInstance {
        uint256 DefimonId;
        uint256 farmingBeginningTime;
        uint256 amount;
        bool isActive;
    }
    
    // 1 address can only farmed 1 Defimon for a period
    mapping(address => farmingInstance) public farmingInstances;

    // init a farming 
    function farmingDefimon(uint256 _id) public{
        require(canBeFarmed[_id] == true,"This Defimon can't be farmed");
        require(Defimon.balanceOf(msg.sender) > _DefimonAmount(_id), "Value isn't good");
        delete _spots[_getSpotIndex(_id)];
        canBeFarmed[_id] = false;
        Defimon.transferFrom(msg.sender,address(this),_DefimonAmount(_id).mul(1E18));
        farmingInstances[msg.sender] = farmingInstance(_id,now,_DefimonAmount(_id),true);
        DMWStackedOnFarming = DMWStackedOnFarming.add(_DefimonAmount(_id));
    }
    
    // cancel my farming instance
    function renounceFarming() public {
        require(farmingInstances[msg.sender].isActive == true, "You don't have any farming instance");
        Defimon.transferFrom(address(this),msg.sender,farmingInstances[msg.sender].amount.mul(1E18));
        canBeFarmed[farmingInstances[msg.sender].DefimonId] = false;
        delete farmingInstances[msg.sender];
        _spots.push(farmingInstances[msg.sender].DefimonId);
        DMWStackedOnFarming = DMWStackedOnFarming.sub(_DefimonAmount(farmingInstances[msg.sender].DefimonId));
        
    }
    
    // Claim Defimon at the end of farming
    function claimDefimon() public {
        require(farmingInstances[msg.sender].isActive == true, "You don't have any farming instance");
        require(now.sub(farmingInstances[msg.sender].farmingBeginningTime) >= _DefimonDuration(farmingInstances[msg.sender].DefimonId));
        
        Defimon.transferFrom(address(this),msg.sender,farmingInstances[msg.sender].amount.mul(1E18));
        farmed[farmingInstances[msg.sender].DefimonId] = true;
        delete farmingInstances[msg.sender];
        DMWStackedOnFarming = DMWStackedOnFarming.sub(_DefimonAmount(farmingInstances[msg.sender].DefimonId));
    }
    
    // function allow to now the necessary amount for the Defimon farming
    function _DefimonAmount(uint256 _id) private view returns(uint256){
        // function will return amount needed to farm Defimon
        uint256 _amount;
        if(_id >= 1 && _id <= 10){
            _amount = amountForPurpleDefimon;
        } else if(_id >= 11 && _id <= 60){
            _amount = amountForBlueDefimon;
        } else if(_id >= 61 && _id <= 160){
            _amount = amountForRedDefimon;
        }
        return _amount;
    }
    
     // function allow to now the necessary time for the Defimon farming
    function _DefimonDuration(uint256 _id) private view returns(uint256){
        // function will return amount needed to farm Defimon
        uint256 _duration;
        if(_id >= 1 && _id <= 10){
            _duration = PurpleDefimonFarmingTime;
        } else if(_id >= 11 && _id <= 60){
            _duration = blueDefimonFarmingTime;
        } else if(_id >= 61 && _id <= 160){
            _duration = redDefimonFarmingTime;
        }
        return _duration;
    }
    
    function _getSpotIndex(uint256 _id) private view returns(uint256){
        uint256 index;
        for( uint256 i = 0 ; i< _spots.length ; i++){
            if(_spots[i] == _id){
                index = i;
                break;
            }
        }
        return index;
    }
    
    // return spots of farming
    function DefimonSpot() public view returns(uint256[] memory spots){
        return _spots;
    }
    
    // winner of contests will receive Defimon
    function DefimonFor(uint256 _id, address _winner ) public onlyOwner(){
        require(farmed[_id]==false);
        farmed[_id] = true;
        Defimon.Defimon(_winner,_id);
    }

    
}