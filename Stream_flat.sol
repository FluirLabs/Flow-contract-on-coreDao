// Sources flattened with hardhat v2.22.18 https://hardhat.org

// SPDX-License-Identifier: AGPL-3.0 AND MIT

// File @openzeppelin/contracts/utils/Context.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (access/Ownable.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.4) (token/ERC20/extensions/IERC20Permit.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 Permit extension allowing approvals to be made via signatures, as defined in
 * https://eips.ethereum.org/EIPS/eip-2612[EIP-2612].
 *
 * Adds the {permit} method, which can be used to change an account's ERC20 allowance (see {IERC20-allowance}) by
 * presenting a message signed by the account. By not relying on {IERC20-approve}, the token holder account doesn't
 * need to send a transaction, and thus is not required to hold Ether at all.
 *
 * ==== Security Considerations
 *
 * There are two important considerations concerning the use of `permit`. The first is that a valid permit signature
 * expresses an allowance, and it should not be assumed to convey additional meaning. In particular, it should not be
 * considered as an intention to spend the allowance in any specific way. The second is that because permits have
 * built-in replay protection and can be submitted by anyone, they can be frontrun. A protocol that uses permits should
 * take this into consideration and allow a `permit` call to fail. Combining these two aspects, a pattern that may be
 * generally recommended is:
 *
 * ```solidity
 * function doThingWithPermit(..., uint256 value, uint256 deadline, uint8 v, bytes32 r, bytes32 s) public {
 *     try token.permit(msg.sender, address(this), value, deadline, v, r, s) {} catch {}
 *     doThing(..., value);
 * }
 *
 * function doThing(..., uint256 value) public {
 *     token.safeTransferFrom(msg.sender, address(this), value);
 *     ...
 * }
 * ```
 *
 * Observe that: 1) `msg.sender` is used as the owner, leaving no ambiguity as to the signer intent, and 2) the use of
 * `try/catch` allows the permit to fail and makes the code tolerant to frontrunning. (See also
 * {SafeERC20-safeTransferFrom}).
 *
 * Additionally, note that smart contract wallets (such as Argent or Safe) are not able to produce permit signatures, so
 * contracts should have entry points that don't rely on permit.
 */
interface IERC20Permit {
    /**
     * @dev Sets `value` as the allowance of `spender` over ``owner``'s tokens,
     * given ``owner``'s signed approval.
     *
     * IMPORTANT: The same issues {IERC20-approve} has related to transaction
     * ordering also apply here.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `deadline` must be a timestamp in the future.
     * - `v`, `r` and `s` must be a valid `secp256k1` signature from `owner`
     * over the EIP712-formatted function arguments.
     * - the signature must use ``owner``'s current nonce (see {nonces}).
     *
     * For more information on the signature format, see the
     * https://eips.ethereum.org/EIPS/eip-2612#specification[relevant EIP
     * section].
     *
     * CAUTION: See Security Considerations above.
     */
    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external;

    /**
     * @dev Returns the current nonce for `owner`. This value must be
     * included whenever a signature is generated for {permit}.
     *
     * Every successful call to {permit} increases ``owner``'s nonce by one. This
     * prevents a signature from being used multiple times.
     */
    function nonces(address owner) external view returns (uint256);

    /**
     * @dev Returns the domain separator used in the encoding of the signature for {permit}, as defined by {EIP712}.
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view returns (bytes32);
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}


// File @openzeppelin/contracts/utils/Address.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     *
     * Furthermore, `isContract` will also return true if the target contract within
     * the same transaction is already scheduled for destruction by `SELFDESTRUCT`,
     * which only has an effect at the end of a transaction.
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://consensys.net/diligence/blog/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.8.0/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResultFromTarget(target, success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verify that a low level call to smart-contract was successful, and revert (either by bubbling
     * the revert reason or using the provided one) in case of unsuccessful call or if target was not a contract.
     *
     * _Available since v4.8._
     */
    function verifyCallResultFromTarget(
        address target,
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        if (success) {
            if (returndata.length == 0) {
                // only check isContract if the call was successful and the return data is empty
                // otherwise we already know that it was a contract
                require(isContract(target), "Address: call to non-contract");
            }
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    /**
     * @dev Tool to verify that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason or using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            _revert(returndata, errorMessage);
        }
    }

    function _revert(bytes memory returndata, string memory errorMessage) private pure {
        // Look for revert reason and bubble it up if present
        if (returndata.length > 0) {
            // The easiest way to bubble the revert reason is using memory via assembly
            /// @solidity memory-safe-assembly
            assembly {
                let returndata_size := mload(returndata)
                revert(add(32, returndata), returndata_size)
            }
        } else {
            revert(errorMessage);
        }
    }
}


// File @openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.3) (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;



/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    /**
     * @dev Transfer `value` amount of `token` from the calling contract to `to`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    /**
     * @dev Transfer `value` amount of `token` from `from` to `to`, spending the approval given by `from` to the
     * calling contract. If `token` returns no value, non-reverting calls are assumed to be successful.
     */
    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    /**
     * @dev Increase the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 oldAllowance = token.allowance(address(this), spender);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance + value));
    }

    /**
     * @dev Decrease the calling contract's allowance toward `spender` by `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful.
     */
    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, oldAllowance - value));
        }
    }

    /**
     * @dev Set the calling contract's allowance toward `spender` to `value`. If `token` returns no value,
     * non-reverting calls are assumed to be successful. Meant to be used with tokens that require the approval
     * to be set to zero before setting it to a non-zero value, such as USDT.
     */
    function forceApprove(IERC20 token, address spender, uint256 value) internal {
        bytes memory approvalCall = abi.encodeWithSelector(token.approve.selector, spender, value);

        if (!_callOptionalReturnBool(token, approvalCall)) {
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, 0));
            _callOptionalReturn(token, approvalCall);
        }
    }

    /**
     * @dev Use a ERC-2612 signature to set the `owner` approval toward `spender` on `token`.
     * Revert on invalid signature.
     */
    function safePermit(
        IERC20Permit token,
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal {
        uint256 nonceBefore = token.nonces(owner);
        token.permit(owner, spender, value, deadline, v, r, s);
        uint256 nonceAfter = token.nonces(owner);
        require(nonceAfter == nonceBefore + 1, "SafeERC20: permit did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address-functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        require(returndata.length == 0 || abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     *
     * This is a variant of {_callOptionalReturn} that silents catches all reverts and returns a bool instead.
     */
    function _callOptionalReturnBool(IERC20 token, bytes memory data) private returns (bool) {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We cannot use {Address-functionCall} here since this should return false
        // and not revert is the subcall reverts.

        (bool success, bytes memory returndata) = address(token).call(data);
        return
            success && (returndata.length == 0 || abi.decode(returndata, (bool))) && Address.isContract(address(token));
    }
}


// File contracts/libraries/StreamStructs.sol

// Original license: SPDX_License_Identifier: AGPL-3.0
pragma solidity ^0.8.0;

library StreamStructs {

    enum Permission {
        None,      // No permissions
        Sender,
        Recipient,
        Both
    }

    struct StreamData {
        address onBehalfOf;
        address sender;
        address recipient;
        uint256 deposit;
        address tokenAddress;
        uint256 startTime;
        uint256 stopTime;
        uint256 interval;
        uint256 ratePerInterval;
        uint256 remainingBalance;
        uint256 lastWithdrawTime;
        uint256 createdAt;
        uint256 autoWithdrawInterval;
        bool autoWithdraw;
        bool closed;
        bool isActive;
        CliffData cliffData;
        PermissionData permissionData;
        PauseData pauseData;
    }

    struct CliffData {
        uint256 cliffAmount;
        uint256 cliffTime;
        bool cliffClaimed;
    }

    struct PermissionData {
        Permission pauseable;
        Permission closeable;
        Permission recipientModifiable;
    }

    struct PauseData {
        uint256 pausedAt;
        uint256 totalPausedTime;
        address pausedBy;
        bool isPaused;
    }

    struct GlobalConfig {
        address weth;
        address gateway;
        address feeRecipient;
        address autoWithdrawAccount;
        uint256 autoWithdrawFeeForOnce;
        uint256 tokenFeeRate;
    }

    struct initializeStreamData {
        address sender;
        address recipient;
        uint256 deposit;
        address tokenAddress;
        uint256 startTime;
        uint256 stopTime;
        uint256 interval;
        uint256 cliffAmount;
        uint256 cliffTime;
        uint256 autoWithdrawInterval;
        bool autoWithdraw;
        Permission pauseable;
        Permission closeable;
        Permission recipientModifiable;
    }
}


// File contracts/interfaces/IStream.sol

// Original license: SPDX_License_Identifier: AGPL-3.0
pragma solidity ^0.8.0;

interface IStream {
    function tokenFeeRate(address tokenAddress) external view returns (uint256);
    
    function autoWithdrawFeeForOnce() external view returns (uint256);
    
    function autoWithdrawAccount() external view returns (address);
    
    function feeRecipient() external view returns (address);
    
    function getStream(uint256 streamId) external view returns (StreamStructs.StreamData memory);
    
    function balanceOf(uint256 streamId, address account) external view returns (uint256 balance);
    
    function initializeStream(StreamStructs.initializeStreamData calldata streamParams) external payable;
    
    function ExtendFlow(uint256 streamId, uint256 newStopTime) external payable;
    
    function WithdrawFromFlow(uint256 streamId) external;
    
    function closeStream(uint256 streamId) external;
    
    function pauseStream(uint256 streamId) external;
    
    function resumeStream(uint256 streamId) external;
    
    function setNewRecipient(uint256 streamId, address newRecipient) external;
}


// File contracts/libraries/CreateLogic.sol

// Original license: SPDX_License_Identifier: AGPL-3.0
pragma solidity ^0.8.0;



library CreateLogic {
    using SafeERC20 for IERC20;

    // Custom Errors
    error ZeroAddressRecipient();
    error StreamToContract();
    error StreamToSelf();
    error ZeroDeposit();
    error InvalidStartTime();
    error InvalidStopTime();
    error InvalidDuration();
    error InvalidDepositAmount();
    error InsufficientAutoWithdrawFee();

    /**
     * @notice Emits when a stream is successfully created.
     */
    event initializeStream(
        uint256 indexed streamId,
        address indexed sender,
        address indexed recipient,
        uint256 deposit,
        address tokenAddress,
        uint256 startTime,
        uint256 stopTime,
        uint256 interval,
        uint256 cliffAmount,
        uint256 cliffTime,
        uint256 autoWithdrawInterval,
        bool autoWithdraw,
        uint8 pauseable,
        uint8 closeable,
        uint8 recipientModifiable
    );

    function create(
        uint256 streamId,
        uint256 senderValue,
        StreamStructs.GlobalConfig memory globalConfig,
        StreamStructs.initializeStreamData calldata createParams,
        mapping(uint256 => StreamStructs.StreamData) storage streams
    ) internal returns (uint256 autoWithdrawFee) {
        _validateCreateParams(createParams);
        uint256 ratePerInterval = _computeRatePerInterval(createParams);

        streams[streamId] = _buildStreamStruct(createParams, ratePerInterval);
        
        if (msg.sender == globalConfig.gateway) {
            streams[streamId].onBehalfOf = globalConfig.gateway;
        }

        IERC20(createParams.tokenAddress).safeTransferFrom(
            msg.sender, 
            address(this), 
            createParams.deposit
        );

        autoWithdrawFee = _handleAutoWithdrawFee(
            createParams, 
            globalConfig, 
            senderValue
        );

        _processCliffPayment(streamId, createParams, globalConfig, streams);
        _emitStreamCreatedEvent(streamId, streams[streamId]);
    }

    function _validateCreateParams(
        StreamStructs.initializeStreamData memory params
    ) private view {
        if (params.recipient == address(0x00)) revert ZeroAddressRecipient();
        if (params.recipient == address(this)) revert StreamToContract();
        if (params.recipient == params.sender) revert StreamToSelf();
        if (params.deposit == 0) revert ZeroDeposit();
        if (params.startTime < block.timestamp) revert InvalidStartTime();
        if (params.stopTime <= params.startTime) revert InvalidStopTime();
    }

    function _computeRatePerInterval(
        StreamStructs.initializeStreamData memory params
    ) private pure returns (uint256 ratePerInterval) {
        uint256 duration = params.stopTime - params.startTime;
        uint256 delta = duration / params.interval;
        
        if (delta * params.interval != duration) revert InvalidDuration();

        uint256 streamableAmount = params.deposit - params.cliffAmount;
        ratePerInterval = streamableAmount / delta;
        
        if (ratePerInterval * delta != streamableAmount) revert InvalidDepositAmount();
    }

    function _buildStreamStruct(
        StreamStructs.initializeStreamData calldata params,
        uint256 ratePerInterval
    ) private view returns (StreamStructs.StreamData memory) {
        return StreamStructs.StreamData({
            onBehalfOf: address(0x00),
            sender: params.sender,
            recipient: params.recipient,
            deposit: params.deposit,
            tokenAddress: params.tokenAddress,
            startTime: params.startTime,
            stopTime: params.stopTime,
            interval: params.interval,
            ratePerInterval: ratePerInterval,
            remainingBalance: params.deposit,
            lastWithdrawTime: params.startTime,
            createdAt: block.timestamp,
            autoWithdrawInterval: params.autoWithdrawInterval,
            autoWithdraw: params.autoWithdraw,
            closed: false,
            isActive: true,
            cliffData: StreamStructs.CliffData({
                cliffAmount: params.cliffAmount,
                cliffTime: params.cliffTime,
                cliffClaimed: false
            }),
            permissionData: StreamStructs.PermissionData({
                pauseable: params.pauseable,
                closeable: params.closeable,
                recipientModifiable: params.recipientModifiable
            }),
            pauseData: StreamStructs.PauseData({
                pausedAt: 0,
                totalPausedTime: 0,
                pausedBy: address(0x00),
                isPaused: false
            })
        });
    }

    function _handleAutoWithdrawFee(
        StreamStructs.initializeStreamData calldata params,
        StreamStructs.GlobalConfig memory globalConfig,
        uint256 senderValue
    ) private returns (uint256 autoWithdrawFee) {
        if (!params.autoWithdraw) return 0;

        uint256 duration = params.stopTime - params.startTime;
        uint256 intervals = duration / params.autoWithdrawInterval + 1;
        autoWithdrawFee = globalConfig.autoWithdrawFeeForOnce * intervals;
        
        if (senderValue < autoWithdrawFee) revert InsufficientAutoWithdrawFee();
        
        payable(globalConfig.autoWithdrawAccount).transfer(autoWithdrawFee);
    }

    function _processCliffPayment(
        uint256 streamId,
        StreamStructs.initializeStreamData calldata params,
        StreamStructs.GlobalConfig memory globalConfig,
        mapping(uint256 => StreamStructs.StreamData) storage streams
    ) private {
        if (params.cliffAmount == 0) {
            streams[streamId].cliffData.cliffClaimed = true;
            return;
        }

        if (params.cliffTime > block.timestamp) return;

        if (msg.sender == globalConfig.gateway) {
            IERC20(params.tokenAddress).safeTransfer(msg.sender, params.cliffAmount);
        } else {
            _distributeCliffWithFee(params, globalConfig);
        }

        streams[streamId].cliffData.cliffClaimed = true;
        streams[streamId].remainingBalance -= params.cliffAmount;
    }

    function _distributeCliffWithFee(
        StreamStructs.initializeStreamData calldata params,
        StreamStructs.GlobalConfig memory globalConfig
    ) private {
        uint256 feeAmount = params.cliffAmount * globalConfig.tokenFeeRate / 10000;
        uint256 recipientAmount = params.cliffAmount - feeAmount;
        
        IERC20(params.tokenAddress).safeTransfer(globalConfig.feeRecipient, feeAmount);
        IERC20(params.tokenAddress).safeTransfer(params.recipient, recipientAmount);
    }

    function _emitStreamCreatedEvent(
        uint256 streamId,
        StreamStructs.StreamData memory stream
    ) private {
        emit initializeStream(
            streamId, 
            stream.sender, 
            stream.recipient, 
            stream.deposit, 
            stream.tokenAddress, 
            stream.startTime, 
            stream.stopTime, 
            stream.interval,
            stream.cliffData.cliffAmount,
            stream.cliffData.cliffTime,
            stream.autoWithdrawInterval,
            stream.autoWithdraw,
            uint8(stream.permissionData.pauseable),
            uint8(stream.permissionData.closeable),
            uint8(stream.permissionData.recipientModifiable)
        );
    }

    // Public functions for backward compatibility (if needed)
    function verifyinitializeStreamParams(
        StreamStructs.initializeStreamData memory createParams
    ) internal view {
        _validateCreateParams(createParams);
    }

    function calculateRatePerInterval(
        StreamStructs.initializeStreamData memory createParams
    ) internal pure returns (uint256) {
        return _computeRatePerInterval(createParams);
    }

    function emitinitializeStreamEvent(
        uint256 streamId,
        StreamStructs.StreamData memory stream
    ) internal {
        _emitStreamCreatedEvent(streamId, stream);
    }
}


// File contracts/libraries/ExtendLogic.sol

// Original license: SPDX_License_Identifier: AGPL-3.0
pragma solidity ^0.8.0;



library ExtendLogic {
    using SafeERC20 for IERC20;

    /**
     * @notice Emits when a stream is successfully extended.
     */
    event ExtendFlow(uint256 indexed streamId, address indexed operator, uint256 stopTime, uint256 deposit);

    // Custom Errors for better gas efficiency and clearer error handling
    error InvalidStopTime();
    error StreamPaused();
    error StreamClosed();
    error UnauthorizedExtension();
    error InvalidDuration();
    error InsufficientAutoWithdrawFee();

    function ExtendFlow(
        uint256 streamId, 
        uint256 stopTime,
        uint256 senderValue,
        StreamStructs.GlobalConfig memory globalConfig,
        StreamStructs.StreamData storage stream
    )
        internal
        returns (uint256 autoWithdrawFee)
    {
        // Validate extend conditions
        if (stopTime <= stream.stopTime) revert InvalidStopTime();
        if (stream.pauseData.isPaused) revert StreamPaused();
        if (stream.closed) revert StreamClosed();
        
        // Check authorization - removed WETH condition as per pattern
        if (msg.sender != stream.sender && msg.sender != stream.onBehalfOf) {
            revert UnauthorizedExtension();
        }

        uint256 duration = stopTime - stream.stopTime;
        uint256 delta = duration / stream.interval;
        if (delta * stream.interval != duration) revert InvalidDuration();

        /* auto withdraw fee */
        if (stream.autoWithdraw) {
            autoWithdrawFee = globalConfig.autoWithdrawFeeForOnce * (duration / stream.autoWithdrawInterval + 1);
            if (senderValue < autoWithdrawFee) revert InsufficientAutoWithdrawFee();
            payable(globalConfig.autoWithdrawAccount).transfer(autoWithdrawFee);
        }

        uint256 newDeposit = delta * stream.ratePerInterval;

        stream.stopTime = stopTime;
        stream.deposit = stream.deposit + newDeposit;
        stream.remainingBalance = stream.remainingBalance + newDeposit;

        IERC20(stream.tokenAddress).safeTransferFrom(msg.sender, address(this), newDeposit);

        emit ExtendFlow(streamId, msg.sender, stopTime, newDeposit);
    }

    // Alternative version with require statements and meaningful messages
    function ExtendFlowWithRequires(
        uint256 streamId, 
        uint256 stopTime,
        uint256 senderValue,
        StreamStructs.GlobalConfig memory globalConfig,
        StreamStructs.StreamData storage stream
    )
        internal
        returns (uint256 autoWithdrawFee)
    {
        require(stopTime > stream.stopTime, "ExtendLogic: new stop time must be after current stop time");
        require(!stream.pauseData.isPaused, "ExtendLogic: cannot extend paused stream");
        require(!stream.closed, "ExtendLogic: cannot extend closed stream");
        require(
            msg.sender == stream.sender || msg.sender == stream.onBehalfOf, 
            "ExtendLogic: only sender or authorized party can extend stream"
        );

        uint256 duration = stopTime - stream.stopTime;
        uint256 delta = duration / stream.interval;
        require(
            delta * stream.interval == duration, 
            "ExtendLogic: extension duration must be multiple of stream interval"
        );

        /* auto withdraw fee */
        if (stream.autoWithdraw) {
            autoWithdrawFee = globalConfig.autoWithdrawFeeForOnce * (duration / stream.autoWithdrawInterval + 1);
            require(
                senderValue >= autoWithdrawFee, 
                "ExtendLogic: insufficient value provided for auto-withdraw fees"
            );
            payable(globalConfig.autoWithdrawAccount).transfer(autoWithdrawFee);
        }

        uint256 newDeposit = delta * stream.ratePerInterval;

        stream.stopTime = stopTime;
        stream.deposit = stream.deposit + newDeposit;
        stream.remainingBalance = stream.remainingBalance + newDeposit;

        IERC20(stream.tokenAddress).safeTransferFrom(msg.sender, address(this), newDeposit);

        emit ExtendFlow(streamId, msg.sender, stopTime, newDeposit);
    }

    // Backward compatibility function
    function extend(
        uint256 streamId, 
        uint256 stopTime,
        uint256 senderValue,
        StreamStructs.GlobalConfig memory globalConfig,
        StreamStructs.StreamData storage stream
    )
        internal
        returns (uint256 autoWithdrawFee)
    {
        return ExtendFlow(streamId, stopTime, senderValue, globalConfig, stream);
    }
}


// File contracts/libraries/WithdrawLogic.sol

// Original license: SPDX_License_Identifier: AGPL-3.0
pragma solidity ^0.8.0;



library WithdrawLogic {
    using SafeERC20 for IERC20;

    /**
     * @notice Emits when the recipient of a stream withdraws a portion or all their pro rata share of the stream.
     */
    event WithdrawFromFlow(uint256 indexed streamId, address indexed operator, uint256 recipientBalance);

    function processWithdrawal(
        uint256 streamId,
        uint256 delta,
        uint256 balance,
        StreamStructs.GlobalConfig memory globalConfig,
        StreamStructs.StreamData storage stream
    )
        internal
    {
        require(stream.pauseData.isPaused == false, "vesting  is paused");
        require(stream.closed == false, "vesting is closed");

        stream.remainingBalance = stream.remainingBalance - balance;
        if (delta > 0) {
            stream.lastWithdrawTime += stream.interval * delta + stream.pauseData.totalPausedTime;
            stream.pauseData.totalPausedTime = 0;
        }


        if (msg.sender == stream.onBehalfOf) {
            IERC20(stream.tokenAddress).safeTransfer(stream.onBehalfOf, balance);
        } else {
            uint256 fee = balance * globalConfig.tokenFeeRate / 10000;
            IERC20(stream.tokenAddress).safeTransfer(globalConfig.feeRecipient, fee);
            IERC20(stream.tokenAddress).safeTransfer(stream.recipient, balance - fee);
        }

        /* cliff */
        if (stream.cliffData.cliffClaimed == false && stream.cliffData.cliffTime <= block.timestamp) {
            stream.cliffData.cliffClaimed = true;
        }

        emit WithdrawFromFlow(streamId, msg.sender, balance);
    }

    // Backward compatibility function (if needed)
    function withdraw(
        uint256 streamId,
        uint256 delta,
        uint256 balance,
        StreamStructs.GlobalConfig memory globalConfig,
        StreamStructs.StreamData storage stream
    )
        internal
    {
        processWithdrawal(streamId, delta, balance, globalConfig, stream);
    }
}


// File @openzeppelin/contracts/security/ReentrancyGuard.sol@v4.9.6

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be _NOT_ENTERED
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}


// File contracts/Stream.sol

// Original license: SPDX_License_Identifier: AGPL-3.0
pragma solidity ^0.8.0;








/**
 * @title PaymentStream Contract
 * @dev Implementation of streaming payment functionality with pause/resume capabilities
 */
contract Stream is IStream, ReentrancyGuard, Ownable {
    using SafeERC20 for IERC20;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    
    address public WETH;
    address public GATEWAY;

    /// @dev Incremental counter for generating unique stream identifiers
    uint256 public nextStreamId;

    // Private state variables for fee management
    address private _protocolFeeCollector;
    address private _automatedWithdrawWallet;
    uint256 private _singleWithdrawFee;

    // Token whitelist and fee configuration
    mapping(address => bool) private _approvedTokens;
    mapping(address => uint256) private _tokenProtocolFee;

    /// @dev Core stream data storage mapped by stream ID
    mapping(uint256 => StreamStructs.StreamData) private _streamRegistry;

    /*//////////////////////////////////////////////////////////////
                                MODIFIERS
    //////////////////////////////////////////////////////////////*/
    
    /// @dev Validates that the stream ID corresponds to an existing stream
    modifier onlyValidStream(uint256 streamId) {
        require(_streamRegistry[streamId].isActive, "stream does not exist");
        _;
    }

    /*//////////////////////////////////////////////////////////////
                                EVENTS
    //////////////////////////////////////////////////////////////*/

    /// @notice Emitted when a stream is terminated and remaining funds are distributed
    event StreamClosed(
        uint256 indexed streamId,
        address indexed operator,
        uint256 senderBalance,
        uint256 recipientBalance
    );

    /// @notice Emitted when stream payments are temporarily halted
    event StreamPaused(
        uint256 indexed streamId,
        address indexed operator,
        uint256 recipientBalance
    );

    /// @notice Emitted when a paused stream is reactivated
    event StreamResumed(
        uint256 indexed streamId,
        address indexed operator,
        uint256 duration
    );

    /// @notice Emitted when stream beneficiary is updated
    event RecipientUpdated(
        uint256 indexed streamId,
        address indexed operator,
        address indexed newRecipient
    );

    /// @notice Emitted when a new token is whitelisted for streaming
    event TokenWhitelisted(address indexed tokenAddress, uint256 feeRate);

    /*//////////////////////////////////////////////////////////////
                            CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(
        address owner_,
        address weth_,
        address protocolFeeCollector_, 
        address automatedWithdrawWallet_,
        uint256 singleWithdrawFee_
    ) Ownable() ReentrancyGuard() {
        _transferOwnership(owner_);
        WETH = weth_;
        _protocolFeeCollector = protocolFeeCollector_;
        _automatedWithdrawWallet = automatedWithdrawWallet_;
        _singleWithdrawFee = singleWithdrawFee_;
        nextStreamId = 100000;
    }

    /*//////////////////////////////////////////////////////////////
                            VIEW FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Returns the protocol fee rate for a specific token
    function tokenFeeRate(address tokenAddress) 
        external 
        view 
        override 
        returns (uint256) 
    {
        require(_approvedTokens[tokenAddress], "token not registered");
        return _tokenProtocolFee[tokenAddress];
    }

    /// @notice Returns the fee charged for automated withdrawals
    function autoWithdrawFeeForOnce() 
        external 
        view 
        override 
        returns (uint256) 
    {
        return _singleWithdrawFee;
    }

    /// @notice Returns the wallet address for automated withdrawals
    function autoWithdrawAccount() 
        external 
        view 
        override 
        returns (address) 
    {
        return _automatedWithdrawWallet;
    }

    /// @notice Returns the protocol fee collector address
    function feeRecipient() 
        external 
        view 
        override 
        returns (address) 
    {
        return _protocolFeeCollector;
    }

    /// @notice Retrieves complete stream information by ID
    /// @param streamId The unique identifier of the stream
    /// @return Complete stream data structure
    function getStream(uint256 streamId)
        external
        view
        override
        onlyValidStream(streamId)
        returns (StreamStructs.StreamData memory)
    {
        return _streamRegistry[streamId];
    }

    /// @notice Calculates elapsed time intervals for stream payments
    /// @dev Returns 0 if current time is before stream start + pause time
    /// @param streamId The stream identifier to query
    /// @return delta Number of payment intervals elapsed
    function deltaOf(uint256 streamId) 
        public 
        view 
        onlyValidStream(streamId) 
        returns (uint256 delta) 
    {
        StreamStructs.StreamData memory streamData = _streamRegistry[streamId];
        
        uint256 effectiveStartTime = streamData.lastWithdrawTime + streamData.pauseData.totalPausedTime;
        if (block.timestamp < effectiveStartTime) {
            return 0;
        }

        uint256 endTime = block.timestamp > streamData.stopTime 
            ? streamData.stopTime 
            : block.timestamp;
        
        return (endTime - streamData.lastWithdrawTime - streamData.pauseData.totalPausedTime) / streamData.interval;
    }

    /// @notice Calculates available balance for withdrawal by a specific address
    /// @param streamId The stream identifier
    /// @param account The address to check balance for
    /// @return balance Available funds for the specified account
    function balanceOf(uint256 streamId, address account)
        public
        view
        override
        onlyValidStream(streamId)
        returns (uint256 balance)
    {
        StreamStructs.StreamData memory streamData = _streamRegistry[streamId];

        uint256 intervalsPassed = deltaOf(streamId);
        uint256 streamedAmount = intervalsPassed * streamData.ratePerInterval;
        
        // Add cliff amount if applicable
        if (!streamData.cliffData.cliffClaimed && 
            streamData.cliffData.cliffTime <= block.timestamp) {
            streamedAmount += streamData.cliffData.cliffAmount;
        }

        if (account == streamData.recipient) {
            return streamedAmount;
        } else if (account == streamData.sender) {
            return streamData.remainingBalance - streamedAmount;
        }
        
        return 0;
    }

    /*//////////////////////////////////////////////////////////////
                        STREAM MANAGEMENT FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Creates multiple streams in a single transaction
    function batchinitializeStream(StreamStructs.initializeStreamData[] calldata streamParams) 
        external 
        payable 
        nonReentrant 
    {
        uint256 remainingValue = msg.value;
        
        for (uint256 i = 0; i < streamParams.length; i++) {
            require(_approvedTokens[streamParams[i].tokenAddress], "token not registered");

            uint256 withdrawFeeUsed = CreateLogic.create(
                nextStreamId,
                remainingValue,
                StreamStructs.GlobalConfig({
                    weth: WETH,
                    gateway: GATEWAY,
                    feeRecipient: _protocolFeeCollector,
                    autoWithdrawAccount: _automatedWithdrawWallet,
                    autoWithdrawFeeForOnce: _singleWithdrawFee,
                    tokenFeeRate: _tokenProtocolFee[streamParams[i].tokenAddress]
                }),
                streamParams[i],
                _streamRegistry
            );

            remainingValue -= withdrawFeeUsed;
            nextStreamId = nextStreamId + 1;
        }

        // Refund unused ETH
        payable(msg.sender).transfer(remainingValue);
    }

    /// @notice Creates a single payment stream
    function initializeStream(StreamStructs.initializeStreamData calldata streamParams)
        external
        payable
        override
        nonReentrant
    {
        require(_approvedTokens[streamParams.tokenAddress], "token not registered");

        uint256 feeConsumed = CreateLogic.create(
            nextStreamId,
            msg.value,
            StreamStructs.GlobalConfig({
                weth: WETH,
                gateway: GATEWAY,
                feeRecipient: _protocolFeeCollector,
                autoWithdrawAccount: _automatedWithdrawWallet,
                autoWithdrawFeeForOnce: _singleWithdrawFee,
                tokenFeeRate: _tokenProtocolFee[streamParams.tokenAddress]
            }),
            streamParams,
            _streamRegistry
        );

        nextStreamId = nextStreamId + 1;
        
        // Return excess ETH to sender
        payable(msg.sender).transfer(msg.value - feeConsumed);
    }

    /// @notice Extends multiple streams' duration in batch
    function batchExtendFlow(uint256[] calldata streamIds, uint256[] calldata newStopTimes) 
        external 
        payable 
        nonReentrant 
    {
        require(streamIds.length == newStopTimes.length, "length not match");
        
        uint256 remainingValue = msg.value;
        
        for (uint256 i = 0; i < streamIds.length; i++) {
            StreamStructs.StreamData storage streamData = _streamRegistry[streamIds[i]];
            require(streamData.isActive, "stream does not exist");
            
            uint256 extensionFee = ExtendLogic.extend(
                streamIds[i],
                newStopTimes[i],
                remainingValue,
                StreamStructs.GlobalConfig({
                    weth: WETH,
                    gateway: GATEWAY,
                    feeRecipient: _protocolFeeCollector,
                    autoWithdrawAccount: _automatedWithdrawWallet,
                    autoWithdrawFeeForOnce: _singleWithdrawFee,
                    tokenFeeRate: _tokenProtocolFee[streamData.tokenAddress]
                }),
                streamData
            );

            remainingValue -= extensionFee;
        }

        payable(msg.sender).transfer(remainingValue);
    }

    /// @notice Extends a single stream's duration
    function ExtendFlow(uint256 streamId, uint256 newStopTime)
        external
        payable
        override
        nonReentrant
        onlyValidStream(streamId)
    {
        StreamStructs.StreamData storage streamData = _streamRegistry[streamId];

        uint256 extensionCost = ExtendLogic.extend(
            streamId,
            newStopTime,
            msg.value,
            StreamStructs.GlobalConfig({
                weth: WETH,
                gateway: GATEWAY,
                feeRecipient: _protocolFeeCollector,
                autoWithdrawAccount: _automatedWithdrawWallet,
                autoWithdrawFeeForOnce: _singleWithdrawFee,
                tokenFeeRate: _tokenProtocolFee[streamData.tokenAddress]
            }),
            streamData
        );

        payable(msg.sender).transfer(msg.value - extensionCost);
    }

    /// @notice Processes withdrawals for multiple streams
    function batchWithdrawFromFlow(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            WithdrawFromFlow(streamIds[i]);
        }
    }

    /// @notice Withdraws available tokens from a stream to the recipient
    /// @param streamId The identifier of the stream to withdraw from
    function WithdrawFromFlow(uint256 streamId)
        public
        override
        onlyValidStream(streamId)
    {
        StreamStructs.StreamData storage streamData = _streamRegistry[streamId];

        uint256 intervalsPassed = deltaOf(streamId);
        uint256 availableBalance = balanceOf(streamId, streamData.recipient);

        require(availableBalance > 0, "no balance to withdraw");

        WithdrawLogic.withdraw(
            streamId,
            intervalsPassed,
            availableBalance,
            StreamStructs.GlobalConfig({
                weth: WETH,
                gateway: GATEWAY,
                feeRecipient: _protocolFeeCollector,
                autoWithdrawAccount: _automatedWithdrawWallet,
                autoWithdrawFeeForOnce: _singleWithdrawFee,
                tokenFeeRate: _tokenProtocolFee[streamData.tokenAddress]
            }),
            streamData
        );
    }

    /// @notice Terminates multiple streams and distributes remaining funds
    function batchCloseStream(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            closeStream(streamIds[i]);
        }
    }

    /// @notice Terminates a stream and distributes remaining tokens proportionally
    /// @dev Only sender or recipient can close based on stream permissions
    /// @param streamId The identifier of the stream to terminate
    function closeStream(uint256 streamId)
        public
        override
        onlyValidStream(streamId)
    {
        StreamStructs.StreamData memory streamData = _streamRegistry[streamId];
        require(!streamData.closed, "stream is closed");

        uint256 intervalsPassed = deltaOf(streamId);
        uint256 senderBalance = balanceOf(streamId, streamData.sender);
        uint256 recipientBalance = balanceOf(streamId, streamData.recipient);

        // Handle WETH streams with gateway logic
        if (WETH == streamData.tokenAddress && msg.sender == streamData.onBehalfOf) {
            _validateClosePermissionForGateway(streamData);
            IERC20(streamData.tokenAddress).safeTransfer(
                streamData.onBehalfOf,
                _streamRegistry[streamId].remainingBalance
            );
        } else {
            _validateClosePermission(streamData);
            _distributeStreamFunds(streamId, streamData, recipientBalance, senderBalance);
        }

        // Handle cliff vesting
        if (!streamData.cliffData.cliffClaimed) {
            _streamRegistry[streamId].cliffData.cliffClaimed = true;
        }

        // Update stream state
        if (intervalsPassed > 0) {
            _streamRegistry[streamId].lastWithdrawTime += 
                streamData.interval * intervalsPassed + streamData.pauseData.totalPausedTime;
            _streamRegistry[streamId].pauseData.totalPausedTime = 0;
        }

        _streamRegistry[streamId].closed = true;
        _streamRegistry[streamId].remainingBalance = 0;

        emit StreamClosed(streamId, msg.sender, senderBalance, recipientBalance);
    }

    /// @notice Pauses multiple streams simultaneously
    function batchPauseStream(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            pauseStream(streamIds[i]);
        }
    }

    /// @notice Temporarily halts stream payments
    function pauseStream(uint256 streamId)
        public
        override
        onlyValidStream(streamId)
    {
        StreamStructs.StreamData storage streamData = _streamRegistry[streamId];
        
        _validatePauseConditions(streamData);
        
        // Handle permission validation and set pause initiator
        if (WETH == streamData.tokenAddress && msg.sender == streamData.onBehalfOf) {
            _setPausePermissionForGateway(streamData);
        } else {
            _setPausePermission(streamData);
        }

        // Process any pending withdrawals before pausing
        uint256 pendingBalance = balanceOf(streamId, streamData.recipient);
        if (pendingBalance > 0) {
            WithdrawLogic.withdraw(
                streamId,
                deltaOf(streamId),
                pendingBalance,
                StreamStructs.GlobalConfig({
                    weth: WETH,
                    gateway: GATEWAY,
                    feeRecipient: _protocolFeeCollector,
                    autoWithdrawAccount: _automatedWithdrawWallet,
                    autoWithdrawFeeForOnce: _singleWithdrawFee,
                    tokenFeeRate: _tokenProtocolFee[streamData.tokenAddress]
                }),
                streamData
            );
        }

        // Activate pause state
        streamData.pauseData.pausedAt = block.timestamp;
        streamData.pauseData.isPaused = true;

        emit StreamPaused(streamId, streamData.pauseData.pausedBy, pendingBalance);
    }

    /// @notice Resumes multiple paused streams
    function batchResumeStream(uint256[] calldata streamIds) external {
        for (uint256 i = 0; i < streamIds.length; i++) {
            resumeStream(streamIds[i]);
        }
    }

    /// @notice Reactivates a paused stream
    function resumeStream(uint256 streamId)
        public
        override
        onlyValidStream(streamId)
    {
        StreamStructs.StreamData storage streamData = _streamRegistry[streamId];
        
        require(streamData.pauseData.isPaused, "stream is not paused");
        require(!streamData.closed, "stream is closed");
        require(
            streamData.pauseData.pausedBy == msg.sender || owner() == msg.sender,
            "only the one who paused the stream can resume it"
        );

        // Calculate pause duration and adjust stream timing
        uint256 pauseDuration = _calculatePauseDuration(streamData);

        streamData.pauseData.isPaused = false;
        streamData.pauseData.pausedAt = 0;
        streamData.pauseData.pausedBy = address(0x00);
        streamData.pauseData.totalPausedTime += pauseDuration;
        streamData.stopTime += pauseDuration;

        emit StreamResumed(streamId, msg.sender, pauseDuration);
    }

    /// @notice Updates recipients for multiple streams
    function batchSetNewRecipient(uint256[] calldata streamIds, address[] calldata newRecipients) 
        external 
    {
        require(streamIds.length == newRecipients.length, "length not match");

        for (uint256 i = 0; i < streamIds.length; i++) {
            setNewRecipient(streamIds[i], newRecipients[i]);
        }
    }

    /// @notice Changes the beneficiary of a stream
    function setNewRecipient(uint256 streamId, address newRecipient)
        public
        override
        onlyValidStream(streamId)
    {
        StreamStructs.StreamData storage streamData = _streamRegistry[streamId];
        require(!streamData.closed, "stream is closed");
        require(!streamData.pauseData.isPaused, "stream is paused");

        _validateRecipientChangePermission(streamData);

        streamData.recipient = newRecipient;

        emit RecipientUpdated(streamId, msg.sender, newRecipient);
    }

    /*//////////////////////////////////////////////////////////////
                        ADMIN FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    /// @notice Adds a token to the whitelist with specified fee rate
    function tokenRegister(address tokenAddress, uint256 feeRate) 
        public 
        onlyOwner 
    {
        _approvedTokens[tokenAddress] = true;
        _tokenProtocolFee[tokenAddress] = feeRate;

        emit TokenWhitelisted(tokenAddress, feeRate);
    }

    /// @notice Batch registers multiple tokens
    function batchTokenRegister(address[] calldata tokenAddresses, uint256[] calldata feeRates) 
        external 
        onlyOwner 
    {
        require(tokenAddresses.length == feeRates.length, "length not match");

        for (uint256 i = 0; i < tokenAddresses.length; i++) {
            tokenRegister(tokenAddresses[i], feeRates[i]);
        }
    }

    /// @notice Updates the protocol fee collector address
    function setFeeRecipient(address newFeeRecipient) external onlyOwner {
        _protocolFeeCollector = newFeeRecipient;
    }

    /// @notice Updates the automated withdrawal account
    function setAutoWithdrawAccount(address newWithdrawAccount) external onlyOwner {
        _automatedWithdrawWallet = newWithdrawAccount;
    }

    /// @notice Updates the automated withdrawal fee
    function setAutoWithdrawFee(uint256 newWithdrawFee) external onlyOwner {
        _singleWithdrawFee = newWithdrawFee;
    }

    /// @notice Updates the gateway contract address
    function setGateway(address gateway) external onlyOwner {
        GATEWAY = gateway;
    }

    /*//////////////////////////////////////////////////////////////
                        INTERNAL HELPER FUNCTIONS
    //////////////////////////////////////////////////////////////*/

    function _validateClosePermission(StreamStructs.StreamData memory streamData) private view {
        if (msg.sender == streamData.sender) {
            require(
                streamData.permissionData.closeable == StreamStructs.Permission.Both ||
                streamData.permissionData.closeable == StreamStructs.Permission.Sender,
                "sender is not allowed to close the stream"
            );
        } else if (msg.sender == streamData.recipient) {
            require(
                streamData.permissionData.closeable == StreamStructs.Permission.Both ||
                streamData.permissionData.closeable == StreamStructs.Permission.Recipient,
                "recipient is not allowed to close the stream"
            );
        } else {
            revert("not allowed to close the stream");
        }
    }

    function _validateClosePermissionForGateway(StreamStructs.StreamData memory streamData) private view {
        if (tx.origin == streamData.sender) {
            require(
                streamData.permissionData.closeable == StreamStructs.Permission.Both ||
                streamData.permissionData.closeable == StreamStructs.Permission.Sender,
                "sender is not allowed to close the stream"
            );
        } else if (tx.origin == streamData.recipient) {
            require(
                streamData.permissionData.closeable == StreamStructs.Permission.Both ||
                streamData.permissionData.closeable == StreamStructs.Permission.Recipient,
                "recipient is not allowed to close the stream"
            );
        } else {
            revert("not allowed to close the stream");
        }
    }

    function _distributeStreamFunds(
        uint256 streamId,
        StreamStructs.StreamData memory streamData,
        uint256 recipientBalance,
        uint256 senderBalance
    ) private {
        if (recipientBalance > 0) {
            uint256 protocolFee = (recipientBalance * _tokenProtocolFee[streamData.tokenAddress]) / 10000;
            IERC20(streamData.tokenAddress).safeTransfer(_protocolFeeCollector, protocolFee);
            IERC20(streamData.tokenAddress).safeTransfer(
                streamData.recipient,
                recipientBalance - protocolFee
            );
        }
        if (senderBalance > 0) {
            IERC20(streamData.tokenAddress).safeTransfer(streamData.sender, senderBalance);
        }
    }

    function _validatePauseConditions(StreamStructs.StreamData memory streamData) private view {
        require(!streamData.pauseData.isPaused, "vesting is paused");
        require(!streamData.closed, "vesting is closed");
        require(streamData.stopTime > block.timestamp, "vesting is expired");
    }

    function _setPausePermission(StreamStructs.StreamData storage streamData) private {
        if (msg.sender == streamData.sender) {
            require(
                streamData.permissionData.pauseable == StreamStructs.Permission.Both ||
                streamData.permissionData.pauseable == StreamStructs.Permission.Sender,
                "sender is not allowed to pause the stream"
            );
            streamData.pauseData.pausedBy = streamData.sender;
        } else if (msg.sender == streamData.recipient) {
            require(
                streamData.permissionData.pauseable == StreamStructs.Permission.Both ||
                streamData.permissionData.pauseable == StreamStructs.Permission.Recipient,
                "recipient is not allowed to pause the stream"
            );
            streamData.pauseData.pausedBy = streamData.recipient;
        } else {
            revert("not allowed to pause the stream");
        }
    }

    function _setPausePermissionForGateway(StreamStructs.StreamData storage streamData) private {
        if (tx.origin == streamData.sender) {
            require(
                streamData.permissionData.pauseable == StreamStructs.Permission.Both ||
                streamData.permissionData.pauseable == StreamStructs.Permission.Sender,
                "sender is not allowed to pause the stream"
            );
            streamData.pauseData.pausedBy = streamData.sender;
        } else if (tx.origin == streamData.recipient) {
            require(
                streamData.permissionData.pauseable == StreamStructs.Permission.Both ||
                streamData.permissionData.pauseable == StreamStructs.Permission.Recipient,
                "recipient is not allowed to pause the stream"
            );
            streamData.pauseData.pausedBy = streamData.recipient;
        } else {
            revert("not allowed to pause the stream");
        }
    }

    function _calculatePauseDuration(StreamStructs.StreamData memory streamData) private view returns (uint256) {
        uint256 duration = 0;
        if (block.timestamp > streamData.startTime) {
            if (streamData.pauseData.pausedAt > streamData.startTime) {
                duration = block.timestamp - streamData.pauseData.pausedAt;
            } else {
                duration = block.timestamp - streamData.startTime;
            }
        }
        return duration;
    }

    function _validateRecipientChangePermission(StreamStructs.StreamData memory streamData) private view {
        if (msg.sender == streamData.sender) {
            require(
                streamData.permissionData.recipientModifiable == StreamStructs.Permission.Both ||
                streamData.permissionData.recipientModifiable == StreamStructs.Permission.Sender,
                "sender is not allowed to change the recipient"
            );
        } else if (msg.sender == streamData.recipient) {
            require(
                streamData.permissionData.recipientModifiable == StreamStructs.Permission.Both ||
                streamData.permissionData.recipientModifiable == StreamStructs.Permission.Recipient,
                "recipient is not allowed to change the recipient"
            );
        } else {
            revert("not allowed to change the recipient");
        }
    }
}
