# Drosera
Drosera Trap
SERGEANT (lvl 3)
Что требуется
— Создай PoC уникальной идеи ловушки ->>>
Создать рабочий прототип уникальной ловушки (Trap),
которая:

-имеет техническую реализацию (код, логика),
-решает реальную проблему или покрывает конкретный use case (например: мониторинг governance-атак, ликвидности, прав доступа и т.д.),
-может быть потенциально применена другими.

Такой PoC может включать:
-Solidity-контракт с логикой ловушки
-описание, какую проблему она решает
-инструкции по деплою и тестированию
примеры сценариев, в которых она полезна

Идея: Ловушка для мониторинга "манипуляций с ликвидностью" в DeFi пулах
Проблема
В DeFi часто происходят манипуляции с ликвидностью — резкие выводы или ввод больших объёмов ликвидности в пул, что может привести к ценовым манипуляциям, слиппеджу и убыткам для обычных пользователей. Такие атаки сложно отследить в реальном времени.

Цель ловушки
Автоматически отслеживать резкие изменения ликвидности в пуле (например, Uniswap, Sushiswap) и сигнализировать о подозрительных действиях — резком снижении или росте ликвидности за короткий промежуток времени.

``` Техническая реализация (PoC)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ITrap} from "drosera-contracts/interfaces/ITrap.sol";

interface IUniswapV2Pair {
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
}

contract LiquidityManipulationTrap is ITrap {
    address public constant PAIR_ADDRESS = 0x...; // адрес пула UniswapV2 или аналогичного
    uint256 public constant THRESHOLD_PERCENT = 30; // порог изменения ликвидности в процентах

    uint112 private lastReserve0;
    uint112 private lastReserve1;

    function collect() external returns (bytes memory) {
        (uint112 reserve0, uint112 reserve1, ) = IUniswapV2Pair(PAIR_ADDRESS).getReserves();

        // Сохраняем последние резервы для сравнения
        lastReserve0 = reserve0;
        lastReserve1 = reserve1;

        return abi.encode(reserve0, reserve1);
    }

    function shouldRespond(bytes[] calldata data) external view returns (bool, bytes memory) {
        (uint112 currentReserve0, uint112 currentReserve1) = abi.decode(data[0], (uint112, uint112));

        // Вычисляем процент изменения по каждому резерву
        uint256 change0 = _percentChange(lastReserve0, currentReserve0);
        uint256 change1 = _percentChange(lastReserve1, currentReserve1);

        if (change0 >= THRESHOLD_PERCENT || change1 >= THRESHOLD_PERCENT) {
            return (true, abi.encode("Liquidity manipulation detected"));
        }

        return (false, bytes(""));
    }

    function _percentChange(uint112 oldVal, uint112 newVal) internal pure returns (uint256) {
        if (oldVal == 0) return 100;
        uint256 diff = oldVal > newVal ? oldVal - newVal : newVal - oldVal;
        return (diff * 100) / oldVal;
    }
}
```

Что решает
Автоматический мониторинг резких изменений ликвидности в DeFi пулах.

Предупреждение операторов и пользователей о возможных манипуляциях и атаках.

Повышение безопасности и прозрачности работы пулов.

Инструкция по деплою и тестированию
Укажите адрес пула в PAIR_ADDRESS.

Задеплойте контракт в тестовой сети.

Настройте операторский нод Drosera для мониторинга.

Проведите тестовые операции с ликвидностью (добавление/удаление) и проверьте срабатывание ловушки.
