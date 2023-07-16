// SPDX-License-Identifier: CC0-1.0
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";

/**
 * @title Non-Fungible Vesting Token Standard
 * @notice A non-fungible token standard used to vest ERC-20 tokens over a vesting release curve
 *  scheduled using timestamps.
 * @dev Because this standard relies on timestamps for the vesting schedule, it's important to keep track of the
 *  tokens claimed per Vesting NFT so that a user cannot withdraw more tokens than alloted for a specific Vesting NFT.
 */
interface IERC5725 is IERC721 {
    /**
     *  This event is emitted when the payout is claimed through the claim function.
     *  @param tokenId The NFT tokenId of the assets being claimed.
     *  @param recipient The address which is receiving the payout.
     *  @param claimAmount The amount of tokens being claimed.
     */
    event PayoutClaimed(uint256 indexed tokenId, address indexed recipient, uint256 claimAmount);

    /**
     *  This event is emitted when an allowance has been increased or decreased.
     *  @param owner The owner of an NFT who's entitled to vested tokens.
     *  @param spender The address who is given permission to spend vested tokens.
     *  @param value The updated amount of tokens that have been approved.
     */
    event ClaimApproval(address owner, address spender, uint256 value);

    /**
     * @notice Claim the pending payout for the NFT.
     * @dev MUST grant the claimablePayout value at the time of claim being called.
     * MUST revert if not called by the token owner or approved users.
     * MUST emit PayoutClaimed.
     * SHOULD revert if there is nothing to claim.
     * @param tokenId The NFT token id.
     */
    function claim(uint256 tokenId) external;

    /**
     * @notice Number of tokens for the NFT which have been claimed at the current timestamp.
     * @param tokenId The NFT token id.
     * @return payout The total amount of payout tokens claimed for this NFT.
     */
    function claimedPayout(uint256 tokenId) external view returns (uint256 payout);

    /**
     * @notice Number of tokens for the NFT which can be claimed at the current timestamp.
     * @dev It is RECOMMENDED that this is calculated as the `vestedPayout()` subtracted from `payoutClaimed()`.
     * @param tokenId The NFT token id.
     * @return payout The amount of unlocked payout tokens for the NFT which have not yet been claimed.
     */
    function claimablePayout(uint256 tokenId) external view returns (uint256 payout);

    /**
     * @notice Total amount of tokens which have been vested at the current timestamp.
     *   This number also includes vested tokens which have been claimed.
     * @dev It is RECOMMENDED that this function calls `vestedPayoutAtTime` with
     *   `block.timestamp` as the `timestamp` parameter.
     * @param tokenId The NFT token id.
     * @return payout Total amount of tokens which have been vested at the current timestamp.
     */
    function vestedPayout(uint256 tokenId) external view returns (uint256 payout);

    /**
     * @notice Total amount of vested tokens at the provided timestamp.
     *   This number also includes vested tokens which have been claimed.
     * @dev `timestamp` MAY be both in the future and in the past.
     * Zero MUST be returned if the timestamp is before the token was minted.
     * @param tokenId The NFT token id.
     * @param timestamp The timestamp to check on, can be both in the past and the future.
     * @return payout Total amount of tokens which have been vested at the provided timestamp.
     */
    function vestedPayoutAtTime(uint256 tokenId, uint256 timestamp) external view returns (uint256 payout);

    /**
     * @notice Number of tokens for an NFT which are currently vesting.
     * @dev The sum of vestedPayout and vestingPayout SHOULD always be the total payout.
     * @param tokenId The NFT token id.
     * @return payout The number of tokens for the NFT which are vesting until a future date.
     */
    function vestingPayout(uint256 tokenId) external view returns (uint256 payout);

    /**
     * @notice The start and end timestamps for the vesting of the provided NFT
     * MUST return the timestamp where no further increase in vestedPayout occurs for `vestingEnd`.
     * @param tokenId The NFT token id.
     * @return vestingStart The beginning of the vesting as a unix timestamp.
     * @return vestingEnd The ending of the vesting as a unix timestamp.
     */
    function vestingPeriod(uint256 tokenId) external view returns (uint256 vestingStart, uint256 vestingEnd);

    /**
     * @notice Token which is used to pay out the vesting claims.
     * @param tokenId The NFT token id.
     * @return token The token which is used to pay out the vesting claims.
     */
    function payoutToken(uint256 tokenId) external view returns (address token);

    /**
     * @notice Atomically increases the allowance granted to `spender` by the caller.
     * @dev `spender` cannot be the zero address.
     * @dev Emits an {ClaimApproval} event indicating the updated allowance value.
     * @param spender The `spender` to be granted allowance.
     * @param addedValue The allowance granted to `spender`.
     */
    function increaseClaimAllowance(address spender, uint256 addedValue) external;
    
    /**
     * @notice Atomically decreases the allowance granted to `spender` by the caller.
     * @dev `spender` cannot be the zero address.
     * @dev Emits an {ClaimApproval} event indicating the updated allowance value.
     * @param spender The `spender` to have allowance reduced.
     * @param subtractedValue The allowance decreased from `spender`.
     */
    function decreaseClaimAllowance(address spender, uint256 subtractedValue) external;

    /**
     * @notice Total amount of allowance granted to a particular `spender`.
     * @dev `owner` cannot be the zero address.
     * @dev `spender` cannot be the zero address.
     * @param owner The allowance giver.
     * @param spender The allowance sender.
     * @return result The number of tokens permitted to be spent by the `spender`.
     */
    function allowance(address owner, address spender) external view returns (uint256 result);
}

