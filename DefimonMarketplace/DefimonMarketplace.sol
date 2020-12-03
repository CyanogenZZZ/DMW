pragma solidity 0.5.17;

import "./Ownable.sol";
import "./Defimon.sol";
import "./DefimonToken.sol";
import "./SafeMath.sol";

// Market Place buy/sell contract

contract MarketPlace is Ownable {
    
    using SafeMath for uint256;
    
    // Tokens used in the farming
    Defimon public Defimon;
    DefimonToken public Defimon;
    
    constructor(Defimon _Defimon, DefimonToken _DefimonToken) public{
        //init Defimon token address
        setDefimonToken(_Defimon);
        setDefimonToken(_DefimonToken);
    }
    
    event newSellingInstance(uint256 _tokenId, uint256 _amountAsked);
    event Defimonold(uint256 _tokenId, address _newOwner);
    event sellingCanceled(uint256 _tokenId);
    
    // =========================================================================================
    // Setting Tokens Functions
    // =========================================================================================

    
    // Set the DefimonToken address
    function setDefimonToken(Defimon _Defimon) public onlyOwner() {
        Defimon = _Defimon;
    }
    
    // Set the DefimonToken address
    function setDefimonToken(DefimonToken _DefimonToken) public onlyOwner() {
        Defimon = _DefimonToken;
    }
    
    // =========================================================================================
    // Setting Tokens Functions
    // =========================================================================================

    //Counter
    uint256 onSaleQuantity = 0;
    uint256[] public tokensOnSale;

    struct sellInstance{
        uint256 tokenId;
        uint256 amountAsked;
        bool onSale;
        address owner;
    }
    
    mapping(uint256 => sellInstance) public sellsInstances;
    
    // sell Defimon
    function sellingDefimon(uint256 _tokenId, uint256 _amountAsked) public {
        require(Defimon.ownerOf(_tokenId) == msg.sender, "Not your Defimon");
        Defimon.transferFrom(msg.sender,address(this),_tokenId);
        sellsInstances[_tokenId] = sellInstance(_tokenId,_amountAsked,true,msg.sender);
        onSaleQuantity = onSaleQuantity.add(1);
        tokensOnSale.push(_tokenId);
        emit newSellingInstance(_tokenId,_amountAsked);
    }
    
    // cancel my selling sellInstance
    function cancelMySellingInstance(uint256 _tokenId)public{
        require(sellsInstances[_tokenId].owner == msg.sender, "Not your Defimon");
        Defimon.transferFrom(address(this),msg.sender,_tokenId);
        uint256 index = getSellingIndexOfToken(_tokenId);
        delete tokensOnSale[index];
        delete sellsInstances[_tokenId];
        onSaleQuantity = onSaleQuantity.sub(1);
        emit sellingCanceled(_tokenId);
    }
    
    // buy the NFT Defimon
    // Need amount of Defimon allowed to contract
    function buyTheDefimon(uint256 _tokenId, uint256 _amount)public{
        require(sellsInstances[_tokenId].onSale == true,"Not on Sale");
        require(_amount == sellsInstances[_tokenId].amountAsked,"Not enough Value");
        uint256 amount = _amount.mul(1E18);
        require(Defimon.balanceOf(msg.sender) > amount, "You don't got enough MGT");
        Defimon.transferFrom(msg.sender,sellsInstances[_tokenId].owner,amount);
        Defimon.transferFrom(address(this),msg.sender,_tokenId);
        uint256 index = getSellingIndexOfToken(_tokenId);
        delete tokensOnSale[index];
        delete sellsInstances[_tokenId];
        onSaleQuantity = onSaleQuantity.sub(1);
        emit Defimonold(_tokenId,msg.sender);
    }
    
    function getSellingIndexOfToken(uint256 _tokenId) private view returns(uint256){
        require(sellsInstances[_tokenId].onSale == true, "Not on sale");
        uint256 index;
        for(uint256 i = 0 ; i< tokensOnSale.length ; i++){
            if(tokensOnSale[i] == _tokenId){
                index = i;
                break;
            }
        }
        return index;
    }
    
}
