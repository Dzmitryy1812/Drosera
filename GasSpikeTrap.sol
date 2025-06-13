// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

contract GasSpikeTrap is ITrap {
    uint256 public constant GAS_PRICE_THRESHOLD = 200 gwei; // порог газа для тревоги

    // В collect можно передавать данные о последней транзакции (например, gasPrice)
    // В реальности данные собирает оператор, здесь пример упрощённый

    function collect() external pure returns (bytes memory) {
        // Здесь оператор должен передать gasPrice последней транзакции
        // Для PoC возвращаем пустой байткод
        return abi.encode(uint256(0));
    }

    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        uint256 gasPrice = abi.decode(data[0], (uint256));

        if (gasPrice >= GAS_PRICE_THRESHOLD) {
            return (true, abi.encode("Gas price spike detected"));
        }
        return (false, bytes(""));
    }
}
