// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract GasSpikeTrap is ITrap {
    uint256 public constant GAS_PRICE_THRESHOLD = 200 gwei; // Gas price threshold for alert

    event AlertTriggered(string message);

    // Returns encoded gas price threshold value
    // Changed from pure to view to satisfy Drosera requirements
    function collect() external view returns (bytes memory) {
        return abi.encode(GAS_PRICE_THRESHOLD);
    }

    // Analyzes input data and decides if response is needed
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        uint256 gasPrice = abi.decode(data[0], (uint256));

        if (gasPrice >= GAS_PRICE_THRESHOLD) {
            return (true, abi.encode("Gas price spike detected"));
        }
        return (false, bytes(""));
    }

    // Alert handler
    function handleAlert(string calldata message) external {
        emit AlertTriggered(message);
        // Add alert processing logic here, e.g., logging or notifications
    }
}
