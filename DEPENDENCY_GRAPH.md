# Dependency Graph - Microservices Architecture

## Complete Dependency Flow

```
┌─────────────────────────────────────────────────────────────┐
│         Market_Scraper_Data_EA.mq5 (Main EA)                │
│  - Includes ONLY service aggregators                         │
│  - No direct microservice includes                           │
└───────┬─────────────────────────────────────────────────────┘
        │
        ├─────► services/trading_tools.mqh
        │       ├─► microservices/core/enums.mqh
        │       ├─► microservices/core/base_structures.mqh
        │       ├─► microservices/utils/array_functions.mqh
        │       ├─► microservices/utils/miscellaneous.mqh
        │       │   └─► microservices/core/enums.mqh
        │       ├─► microservices/utils/money_functions.mqh
        │       │   └─► microservices/core/enums.mqh
        │       └─► microservices/utils/logs_helper.mqh
        │           └─► microservices/core/enums.mqh
        │
        ├─────► services/trading_signals.mqh
        │       ├─► microservices/indicators/bands_percent_indicator.mqh
        │       │   ├─► microservices/core/enums.mqh
        │       │   └─► microservices/core/base_structures.mqh
        │       ├─► microservices/indicators/stochastic_indicator.mqh
        │       │   ├─► microservices/core/enums.mqh
        │       │   └─► microservices/core/base_structures.mqh
        │       ├─► microservices/indicators/stochastic_market_indicator.mqh
        │       │   ├─► microservices/core/enums.mqh
        │       │   ├─► microservices/core/base_structures.mqh
        │       │   ├─► microservices/indicators/extrema_detector.mqh
        │       │   │   ├─► microservices/core/base_structures.mqh
        │       │   │   └─► microservices/utils/array_functions.mqh
        │       │   ├─► microservices/indicators/structure_classifier.mqh
        │       │   │   ├─► microservices/core/enums.mqh
        │       │   │   └─► microservices/indicators/extrema_detector.mqh
        │       │   └─► microservices/indicators/fibonacci_calculator.mqh
        │       │       ├─► microservices/utils/miscellaneous.mqh
        │       │       ├─► microservices/indicators/extrema_detector.mqh
        │       │       └─► microservices/indicators/structure_classifier.mqh
        │       ├─► services/trading_signals/signal_params_struct.mqh
        │       ├─► services/trading_signals/market_signal_crawler.mqh
        │       └─► services/trading_signals/tick_signals_manager.mqh
        │
        ├─────► services/trading_management.mqh
        │       ├─► services/trading_management/market_conditions_functions.mqh
        │       └─► services/trading_management/indicator_definitions_loader.mqh
        │
        ├─────► services/trading_database.mqh
        │       ├─► services/trading_database/initial_database_setup.mqh
        │       └─► services/trading_database/database_signal_wrapper.mqh
        │
        └─────► services/frontend.mqh
                └─► services/frontend/ea_license_light_version.mqh
```

## Microservice Dependencies

### Core Microservices (No dependencies)
```
microservices/core/
├── enums.mqh ✓ [NO DEPENDENCIES]
└── base_structures.mqh ✓ [NO DEPENDENCIES]
```

### Utility Microservices
```
microservices/utils/
├── array_functions.mqh ✓ [NO DEPENDENCIES]
├── miscellaneous.mqh
│   └─► core/enums.mqh
├── money_functions.mqh
│   └─► core/enums.mqh
└── logs_helper.mqh
    └─► core/enums.mqh
```

### Indicator Microservices
```
microservices/indicators/
├── bands_percent_indicator.mqh
│   ├─► core/enums.mqh
│   └─► core/base_structures.mqh
├── body_ma_indicator.mqh
│   ├─► core/enums.mqh
│   └─► core/base_structures.mqh
├── stochastic_indicator.mqh
│   ├─► core/enums.mqh
│   └─► core/base_structures.mqh
├── extrema_detector.mqh
│   ├─► core/base_structures.mqh
│   └─► utils/array_functions.mqh
├── structure_classifier.mqh
│   ├─► core/enums.mqh
│   └─► extrema_detector.mqh
├── fibonacci_calculator.mqh
│   ├─► utils/miscellaneous.mqh
│   ├─► extrema_detector.mqh
│   └─► structure_classifier.mqh
└── stochastic_market_indicator.mqh (Refactored Orchestrator)
    ├─► core/enums.mqh
    ├─► core/base_structures.mqh
    ├─► extrema_detector.mqh
    ├─► structure_classifier.mqh
    └─► fibonacci_calculator.mqh
```

## Include Guard Verification

All files properly protected with include guards:

### Microservices
- ✓ `_MICROSERVICES_CORE_ENUMS_MQH_`
- ✓ `_MICROSERVICES_CORE_BASE_STRUCTURES_MQH_`
- ✓ `_MICROSERVICES_UTILS_ARRAY_FUNCTIONS_MQH_`
- ✓ `_MICROSERVICES_UTILS_MISCELLANEOUS_MQH_`
- ✓ `_MICROSERVICES_UTILS_MONEY_FUNCTIONS_MQH_`
- ✓ `_MICROSERVICES_UTILS_LOGS_HELPER_MQH_`
- ✓ `_MICROSERVICES_INDICATORS_BANDS_PERCENT_INDICATOR_MQH_`
- ✓ `_MICROSERVICES_INDICATORS_BODY_MA_INDICATOR_MQH_`
- ✓ `_MICROSERVICES_INDICATORS_STOCHASTIC_INDICATOR_MQH_`
- ✓ `_MICROSERVICES_INDICATORS_EXTREMA_DETECTOR_MQH_`
- ✓ `_MICROSERVICES_INDICATORS_STRUCTURE_CLASSIFIER_MQH_`
- ✓ `_MICROSERVICES_INDICATORS_FIBONACCI_CALCULATOR_MQH_`
- ✓ `_MICROSERVICES_INDICATORS_STOCHASTIC_MARKET_INDICATOR_MQH_`

### Service Aggregators
- ✓ `_SERVICES_TRADING_TOOLS_MQH_`
- ✓ `_SERVICES_TRADING_SIGNALS_MQH_`
- ✓ `_SERVICES_TRADING_MANAGEMENT_MQH_`
- ✓ `_SERVICES_TRADING_DATABASE_MQH_`
- ✓ `_SERVICES_FRONTEND_MQH_`

### Service Files
- ✓ `_SERVICES_TRADING_SIGNALS_SIGNAL_PARAMS_STRUCT_MQH_`
- ✓ `_SERVICES_TRADING_SIGNALS_MARKET_SIGNAL_CRAWLER_MQH_`
- ✓ `_SERVICES_TRADING_SIGNALS_TICK_SIGNALS_MANAGER_MQH_`
- ✓ `_SERVICES_TRADING_MANAGEMENT_MARKET_CONDITIONS_FUNCTIONS_MQH_`
- ✓ `_SERVICES_TRADING_MANAGEMENT_INDICATOR_DEFINITIONS_LOADER_MQH_`
- ✓ `_SERVICES_TRADING_DATABASE_INITIAL_DATABASE_SETUP_MQH_`
- ✓ `_SERVICES_TRADING_DATABASE_DATABASE_SIGNAL_WRAPPER_MQH_`
- ✓ `_SERVICES_FRONTEND_EA_LICENSE_LIGHT_VERSION_MQH_`

## Circular Dependency Check: ✅ PASSED

No circular dependencies detected in the dependency graph.

### Verification Rules
1. ✅ Microservices never include services
2. ✅ Services only include microservices and their internal files
3. ✅ Main EA only includes service aggregators
4. ✅ All includes use relative paths from project root
5. ✅ All files have unique include guards
6. ✅ Dependency flow is strictly unidirectional

## File Count Summary

| Category | Count |
|----------|-------|
| Microservice Core | 2 |
| Microservice Utils | 4 |
| Microservice Indicators | 7 |
| Service Aggregators | 5 |
| Service Implementation Files | 8 |
| Main EA | 1 |
| **Total** | **27** |

## Compilation Order

When MQL5 compiler processes the main EA, files are included in this order:

1. Standard MQL5 Libraries (Trade, AccountInfo, SymbolInfo)
2. Service Aggregators (in order of include)
3. Each aggregator triggers its dependencies:
   - Core microservices first
   - Utils and indicators next
   - Service implementation files last

This ensures all dependencies are resolved before they're used.

---

**Architecture Status**: ✅ Clean, No Circular Dependencies
**Include Guards**: ✅ All Files Protected
**Dependency Flow**: ✅ Unidirectional

