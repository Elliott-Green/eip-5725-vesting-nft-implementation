// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.17;

import "../BaseVestingNFT.sol";

contract VestingNFT is BaseVestingNFT {
    using SafeERC20 for IERC20;

    struct VestDetails {
        IERC20 payoutToken; /// @dev payout token
        uint256 payout; /// @dev payout token remaining to be paid
        uint128 startTime; /// @dev when vesting starts
        uint128 endTime; /// @dev when vesting end
    }
    mapping(uint256 => VestDetails) public vestDetails; /// @dev maps the vesting data with tokenIds

    /// @dev tracker of current NFT id
    uint256 private _tokenIdTracker;

    /**
     * @dev Initializes the contract by setting a `name` and a `symbol` to the token.
     */
    constructor(string memory name, string memory symbol) ERC721(name, symbol) {}

    /**
     * @notice Creates a new vesting NFT and mints it
     * @dev Token amount should be approved to be transfered by this contract before executing create
     * @param to The recipient of the NFT
     * @param amount The total assets to be locked over time
     * @param releaseTimestamp When the full amount of tokens get released
     * @param token The ERC20 token to vest over time
     */
    function create(
        address to,
        uint256 amount,
        uint128 releaseTimestamp,
        IERC20 token
    ) public virtual {
        require(to != address(0), "to cannot be address 0");

        uint256 newTokenId = _tokenIdTracker;

        vestDetails[newTokenId] = VestDetails({
            payoutToken: token,
            payout: amount,
            startTime: uint128(block.timestamp),
            endTime: releaseTimestamp
        });

        _tokenIdTracker++;
        _mint(to, newTokenId);
        IERC20(payoutToken(newTokenId)).safeTransferFrom(msg.sender, address(this), amount);
    }

    /**
     * @dev See {IVestingNFT}.
     */
    function vestedPayoutAtTime(uint256 tokenId, uint256 timestamp)
        public
        view
        override(BaseVestingNFT)
        validToken(tokenId)
        returns (uint256 payout)
    {
        if (timestamp >= _endTime(tokenId)) {
            return _payout(tokenId);
        }
    }

    /**
     * @dev See {BaseVestingNFT}.
     */
    function _payoutToken(uint256 tokenId) internal view override returns (address) {
        return address(vestDetails[tokenId].payoutToken);
    }

    /**
     * @dev See {BaseVestingNFT}.
     */
    function _payout(uint256 tokenId) internal view override returns (uint256) {
        return vestDetails[tokenId].payout;
    }

    /**
     * @dev See {BaseVestingNFT}.
     */
    function _startTime(uint256 tokenId) internal view override returns (uint256) {
        return vestDetails[tokenId].startTime;
    }

    /**
     * @dev See {BaseVestingNFT}.
     */
    function _endTime(uint256 tokenId) internal view override returns (uint256) {
        return vestDetails[tokenId].endTime;
    }
}
