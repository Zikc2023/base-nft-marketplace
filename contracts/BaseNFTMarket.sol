// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

contract BaseNFTMarket {
    struct Listing {
        address seller;
        uint256 price;
    }

    // Mapping: NFT Contract -> Token ID -> Listing Data
    mapping(address => mapping(uint256 => Listing)) public listings;

    event NFTListed(address indexed nftAddr, uint256 indexed tokenId, uint256 price);
    event NFTSold(address indexed nftAddr, uint256 indexed tokenId, address buyer, uint256 price);

    function listNFT(address _nftAddr, uint256 _tokenId, uint256 _price) external {
        IERC721 nft = IERC721(_nftAddr);
        require(nft.ownerOf(_tokenId) == msg.sender, "Not the owner");
        require(nft.isApprovedForAll(msg.sender, address(this)), "Market not approved");

        listings[_nftAddr][_tokenId] = Listing(msg.sender, _price);
        emit NFTListed(_nftAddr, _tokenId, _price);
    }

    function buyNFT(address _nftAddr, uint256 _tokenId) external payable {
        Listing memory listing = listings[_nftAddr][_tokenId];
        require(msg.value >= listing.price, "Insufficient funds");

        delete listings[_nftAddr][_tokenId];
        IERC721(_nftAddr).safeTransferFrom(listing.seller, msg.sender, _tokenId);
        payable(listing.seller).transfer(msg.value);

        emit NFTSold(_nftAddr, _tokenId, msg.sender, listing.price);
    }
}
