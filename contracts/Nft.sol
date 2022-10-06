// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract MrShephu is ERC721, ERC721Enumerable, Pausable, Ownable {
    uint public maxsupply=3;
    bool public done;
    address[] public whitelist=[0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2,0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2];
    using Counters for Counters.Counter;
    bool public publicmint=true;
    bool public allowmint=true;

    function setmint(bool _p,bool _al)external onlyOwner{
        publicmint=_p;
        allowmint=_al;
    }

    Counters.Counter private _tokenIdCounter;

    constructor() ERC721("MrShephu", "Shephu") {}

    function _baseURI() internal pure override returns (string memory) {
        return "ipfs://Qmaa6TuP2s9pSKczHF4rwWhTKUdygrrDs8RmYYqCjP3Hye/";
    }

    function pause() public onlyOwner {
        _pause();
    }

    function unpause() public onlyOwner {
        _unpause();
    }

    function PublicMint() public payable  {
      require(publicmint==true,"not started yet");
        require(msg.value==0.01 ether,"Not enough Funds");
        require(done==false,"you have aready minted");
        require(totalSupply()<maxsupply,"Nikal");
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        done=true;
    }

    function AllowMint() public payable  {
         require(allowmint==true,"Nikal");
        require(msg.value==1 ether,"Not enough Funds");
        require(done==false,"you have aready minted");
        require(totalSupply()<maxsupply,"the minting has done");
            for(uint i=0;i<whitelist.length;i++)
            { require(msg.sender==whitelist[i],"you are not whitelisted");}

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        done=true;
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId)
        internal
        whenNotPaused
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    function withdraw() external onlyOwner payable{
        payable(msg.sender).transfer(address(this).balance);
    }
}