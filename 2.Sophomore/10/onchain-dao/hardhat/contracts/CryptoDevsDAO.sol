// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

/**
 * Interface for the FakeNFTMarketplace
 */
interface IFakeNFTMarketplace {
    /// @dev getPrice() returns the price of an NFT from the FakeNFTMarketplace
    /// @return Returns the price in Wei for an NFT
    function getPrice() external view returns (uint256);

    /// @dev available() returns whether or not the given _tokenId has already been purchased
    /// @return Returns a boolean value - true if available, false if not
    function available(uint256 _tokenId) external view returns (bool);

    /// @dev purchase() purchases an NFT from the FakeNFTMarketplace
    /// @param _tokenId - the fake NFT tokenID to purchase
    function purchase(uint256 _tokenId) external payable;
}

/**
 * Minimal interface for CryptoDevsNFT containing only two functions
 * that we are interested in
 */
interface ICryptoDevsNFT {
    /// @dev balanceOf returns the number of NFTs owned by the given address
    /// @param owner - address to fetch number of NFTs for
    /// @return Returns the number of NFTs owned
    function balanceOf(address owner) external view returns (uint256);

    /// @dev tokenOfOwnerByIndex returns a tokenID at given index for owner
    /// @param owner - address to fetch the NFT TokenID for
    /// @param index - index of NFT in owned tokens array to fetch
    /// @return Returns the TokenID of the NFT
    function tokenOfOwnerByIndex(address owner, uint256 index)
        external
        view
        returns (uint256);
}

contract CryptoDevsDAO is Ownable {
	struct Proposal {
		uint256 nftTokenId;
		uint256 deadline;
		uint256 yayVotes;
		uint256 nayVotes;
		bool executed;
		mapping(uint256 => bool) voters;
	}

	enum Vote {
		YAY, // YAY = 0
		NAY // NAY = 1
	}

	mapping(uint256 => Proposal) public proposals;
	uint256 public numProposals;

	IFakeNFTMarketplace nftMarketplace;
	ICryptoDevsNFT cryptoDevsNFT;

	constructor(address _nftMarketplace, address _cryptoDevsNFT) payable Ownable(msg.sender) {
		nftMarketplace = IFakeNFTMarketplace(_nftMarketplace);
		cryptoDevsNFT = ICryptoDevsNFT(_cryptoDevsNFT);
	}

	modifier nftHolderOnly() {
		require(cryptoDevsNFT.balanceOf(msg.sender) > 0, "NOT_A_DAO_MEMBER");
		_;
	}

	function createProposal(uint256 _nftTokenId)
		external
		nftHolderOnly
		returns (uint256)
	{
		require(nftMarketplace.available(_nftTokenId), "NFT_NOT_FOR_SALE");
		Proposal storage proposal = proposals[numProposals];
		proposal.nftTokenId = _nftTokenId;
		// Set the proposal's voting deadline to be (current time + 5 minutes)
		proposal.deadline = block.timestamp + 5 minutes;

		numProposals++;

		return numProposals - 1;
	}

	modifier activeProposalOnly(uint256 proposalIndex) {
		require(
			proposals[proposalIndex].deadline > block.timestamp,
			"DEADLINE_EXCEEDED"
		);
		_;
	}

	function voteOnProposal(uint256 proposalIndex, Vote vote)
		external
		nftHolderOnly
		activeProposalOnly(proposalIndex)
	{
		Proposal storage proposal = proposals[proposalIndex];

		uint256 voterNFTBalance = cryptoDevsNFT.balanceOf(msg.sender);
		uint256 numVotes = 0;

		for (uint256 i = 0; i < voterNFTBalance; i++) {
			uint256 tokenId = cryptoDevsNFT.tokenOfOwnerByIndex(msg.sender, i);
			if (proposal.voters[tokenId] == false) {
				numVotes++;
				proposal.voters[tokenId] = true;
			}
		}
		require(numVotes > 0, "ALREADY_VOTED");

		if (vote == Vote.YAY) {
			proposal.yayVotes += numVotes;
		} else {
			proposal.nayVotes += numVotes;
		}
	}

	modifier inactiveProposalOnly(uint256 proposalIndex) {
		require(
			proposals[proposalIndex].deadline <= block.timestamp,
			"DEADLINE_NOT_EXCEEDED"
		);
		require(
			proposals[proposalIndex].executed == false,
			"PROPOSAL_ALREADY_EXECUTED"
		);
		_;
	}

	function executeProposal(uint256 proposalIndex)
		external
		nftHolderOnly
		inactiveProposalOnly(proposalIndex)
	{
		Proposal storage proposal = proposals[proposalIndex];

		if (proposal.yayVotes > proposal.nayVotes) {
			uint256 nftPrice = nftMarketplace.getPrice();
			require(address(this).balance >= nftPrice, "NOT_ENOUGH_FUNDS");
			nftMarketplace.purchase{value: nftPrice}(proposal.nftTokenId);
		}
		proposal.executed = true;
	}

	function withdrawEther() external onlyOwner {
		uint256 amount = address(this).balance;
		require(amount > 0, "Nothing to withdraw, contract balance empty");
		(bool sent, ) = payable(owner()).call{value: amount}("");
		require(sent, "FAILED_TO_WITHDRAW_ETHER");
	}

	receive() external payable {}
	fallback() external payable {}
}