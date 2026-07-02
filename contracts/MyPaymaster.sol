// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IPaymaster, ExecutionResult, PAYMASTER_VALIDATION_SUCCESS_MAGIC} from "@matterlabs/zksync-contracts/contracts/system-contracts/interfaces/IPaymaster.sol";
import {IPaymasterFlow} from "@matterlabs/zksync-contracts/contracts/system-contracts/interfaces/IPaymasterFlow.sol";
import {Transaction} from "@matterlabs/zksync-contracts/contracts/system-contracts/libraries/TransactionHelper.sol";
import {BOOTLOADER_FORMAL_ADDRESS} from "@matterlabs/zksync-contracts/contracts/system-contracts/Constants.sol";

contract MyPaymaster is IPaymaster {
    address public owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function transferOwnership(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }

    receive() external payable {}

    function withdraw(address _to, uint256 _amount) external onlyOwner {
        (bool success,) = _to.call{value: _amount}("");
        require(success, "Withdraw failed");
    }

    function validateAndPayForPaymasterTransaction(
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        Transaction calldata _transaction
    ) external payable returns (bytes4 magic, bytes memory context) {
        require(msg.sender == BOOTLOADER_FORMAL_ADDRESS, "Only bootloader");
        require(
            _transaction.paymasterInput.length >= 4,
            "Invalid paymasterInput"
        );

        bytes4 paymasterFlowSelector = bytes4(
            _transaction.paymasterInput[0:4]
        );
        require(
            paymasterFlowSelector == IPaymasterFlow.general.selector,
            "Only general flow supported"
        );

        uint256 requiredEth = _transaction.gasLimit *
            _transaction.maxFeePerGas;
        require(
            address(this).balance >= requiredEth,
            "Insufficient paymaster balance"
        );

        (bool success,) = BOOTLOADER_FORMAL_ADDRESS.call{value: requiredEth}("");
        require(success, "Failed to pay bootloader");

        magic = PAYMASTER_VALIDATION_SUCCESS_MAGIC;
    }

    function postTransaction(
        bytes calldata _context,
        Transaction calldata _transaction,
        bytes32 _txHash,
        bytes32 _suggestedSignedHash,
        ExecutionResult _txResult,
        uint256 _maxRefundedGas
    ) external payable override {}
}
