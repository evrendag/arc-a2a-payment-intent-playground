// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title PaymentIntentRegistry
/// @notice Escrow-based, human-approved USDC payment intents for agent workflows.
/// @dev The payment token should be the Arc Testnet USDC ERC-20 interface.
contract PaymentIntentRegistry {
    enum Status {
        None,
        Pending,
        Approved,
        Executed,
        Cancelled,
        Expired
    }

    struct PaymentIntent {
        address creator;
        address executor;
        address recipient;
        uint256 amount;
        bytes32 purposeHash;
        uint64 expiry;
        Status status;
    }

    IERC20 public immutable paymentToken;
    uint256 public nextIntentId = 1;
    mapping(uint256 => PaymentIntent) public intents;

    uint256 private _lock = 1;

    event IntentCreated(
        uint256 indexed intentId,
        address indexed creator,
        address indexed recipient,
        address executor,
        uint256 amount,
        bytes32 purposeHash,
        uint64 expiry
    );
    event IntentApproved(uint256 indexed intentId, address indexed approver);
    event IntentExecuted(uint256 indexed intentId, address indexed executor);
    event IntentCancelled(uint256 indexed intentId, address indexed caller);
    event IntentExpired(uint256 indexed intentId, address indexed caller);

    error InvalidAddress();
    error InvalidAmount();
    error InvalidExpiry();
    error UnknownIntent();
    error NotCreator();
    error NotExecutor();
    error WrongStatus();
    error NotExpired();
    error TokenTransferFailed();
    error Reentrancy();

    modifier nonReentrant() {
        if (_lock != 1) revert Reentrancy();
        _lock = 2;
        _;
        _lock = 1;
    }

    constructor(address paymentToken_) {
        if (paymentToken_ == address(0)) revert InvalidAddress();
        paymentToken = IERC20(paymentToken_);
    }

    /// @notice Create an intent and escrow the USDC from the creator.
    /// @dev The creator must first approve this contract for amount.
    function createIntent(
        address recipient,
        address executor,
        uint256 amount,
        bytes32 purposeHash,
        uint64 expiry
    ) external nonReentrant returns (uint256 intentId) {
        if (recipient == address(0) || executor == address(0)) revert InvalidAddress();
        if (amount == 0) revert InvalidAmount();
        if (expiry <= block.timestamp) revert InvalidExpiry();

        if (!paymentToken.transferFrom(msg.sender, address(this), amount)) {
            revert TokenTransferFailed();
        }

        intentId = nextIntentId++;
        intents[intentId] = PaymentIntent({
            creator: msg.sender,
            executor: executor,
            recipient: recipient,
            amount: amount,
            purposeHash: purposeHash,
            expiry: expiry,
            status: Status.Pending
        });

        emit IntentCreated(
            intentId,
            msg.sender,
            recipient,
            executor,
            amount,
            purposeHash,
            expiry
        );
    }

    /// @notice Human approval step. Only the creator can approve.
    function approveIntent(uint256 intentId) external {
        PaymentIntent storage intent = _intent(intentId);
        if (msg.sender != intent.creator) revert NotCreator();
        if (intent.status != Status.Pending) revert WrongStatus();
        if (block.timestamp >= intent.expiry) revert WrongStatus();

        intent.status = Status.Approved;
        emit IntentApproved(intentId, msg.sender);
    }

    /// @notice Release the escrowed USDC to the fixed recipient.
    /// @dev Only the designated executor or creator can execute.
    function executeIntent(uint256 intentId) external nonReentrant {
        PaymentIntent storage intent = _intent(intentId);
        if (msg.sender != intent.executor && msg.sender != intent.creator) {
            revert NotExecutor();
        }
        if (intent.status != Status.Approved) revert WrongStatus();
        if (block.timestamp >= intent.expiry) revert WrongStatus();

        intent.status = Status.Executed;
        if (!paymentToken.transfer(intent.recipient, intent.amount)) {
            revert TokenTransferFailed();
        }

        emit IntentExecuted(intentId, msg.sender);
    }

    /// @notice Cancel a pending or approved intent and refund its creator.
    function cancelIntent(uint256 intentId) external nonReentrant {
        PaymentIntent storage intent = _intent(intentId);
        if (msg.sender != intent.creator) revert NotCreator();
        if (intent.status != Status.Pending && intent.status != Status.Approved) {
            revert WrongStatus();
        }

        intent.status = Status.Cancelled;
        if (!paymentToken.transfer(intent.creator, intent.amount)) {
            revert TokenTransferFailed();
        }

        emit IntentCancelled(intentId, msg.sender);
    }

    /// @notice Anyone can mark an expired intent and refund its creator.
    function expireIntent(uint256 intentId) external nonReentrant {
        PaymentIntent storage intent = _intent(intentId);
        if (intent.status != Status.Pending && intent.status != Status.Approved) {
            revert WrongStatus();
        }
        if (block.timestamp < intent.expiry) revert NotExpired();

        intent.status = Status.Expired;
        if (!paymentToken.transfer(intent.creator, intent.amount)) {
            revert TokenTransferFailed();
        }

        emit IntentExpired(intentId, msg.sender);
    }

    function _intent(uint256 intentId)
        internal
        view
        returns (PaymentIntent storage intent)
    {
        intent = intents[intentId];
        if (intent.status == Status.None) revert UnknownIntent();
    }
}

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}
