# Market Scraper Data EA

**Version:** 1.10
**Platform:** MetaTrader 5 (MQL5)
**Copyright:** Traders Capital Team
**Contact:** @loldlm | https://t.me/TradingAlgoritmicoFx

---

## Overview

The **Market Scraper Data EA** is a specialized Expert Advisor designed to collect and store comprehensive market indicator data into an SQLite database. This tool operates on a tick-by-tick basis, capturing market conditions minute-by-minute across multiple timeframes and indicator periods.

The primary purpose is to build a robust dataset for machine learning, backtesting analysis, and pattern recognition by systematically recording:
- Bollinger Bands (BB) data
- Bollinger Bands Percent (BB%) data
- Stochastic Oscillator values
- Market structure patterns based on stochastic movements

## Key Features

### Data Collection
- **Tick-by-tick processing**: Captures market data on every tick within configured spread limits
- **Multi-timeframe analysis**: Monitors 14 different timeframes (M1-H4) simultaneously
- **Multi-period indicators**: Tracks 5-7 different indicator periods (Fibonacci sequence: 5, 8, 13, 21, 34, 55, 89)
- **Signal detection**: Identifies bullish/bearish signals based on stochastic oversold/overbought levels

### Indicators Tracked

1. **Bollinger Bands (BB)**
   - Standard deviation bands
   - Multiple periods and timeframes

2. **Bollinger Bands Percent (BB%)**
   - Position within bands
   - Signal line values
   - Slope detection (up/down)
   - Percentile classification (0-100 range)
   - Trend identification

3. **Stochastic Oscillator**
   - Main line values (K)
   - Signal line values (D)
   - Slope detection for both lines
   - Percentile classification
   - Overbought/oversold detection (>70 / <30)

4. **Stochastic Market Structure**
   - Higher Highs (HH), Higher Lows (HL)
   - Lower Highs (LH), Lower Lows (LL)
   - Structure timestamps and prices
   - Fibonacci retracement levels

### Database Storage

All data is stored in a normalized SQLite database with WAL (Write-Ahead Logging) mode for optimal performance.

## Database Schema

### MarketDatasetsDB
Root table containing dataset metadata:
- `dataset_id` (UUID): Unique identifier for each dataset
- `name`: System/strategy name
- `source`: Data source (broker company)
- `symbol`: Trading pair (e.g., XAUUSD)
- `symbol_digits`: Symbol precision
- `date_start` / `date_end`: Dataset time range
- `spread_points`: Average spread
- `ea_version`: EA version used
- `build`: MetaTrader build number

### SignalParamsDB
Main signal records:
- `signal_id` (AUTOINCREMENT): Unique signal identifier
- `dataset_id` (FK): Links to MarketDatasetsDB
- `signal_type`: BULLISH (1) or BEARISH (2)
- `signal_state`: WAITING (0), OPENED (1), TRALING (2)
- `entry_price` / `close_price`: Entry and exit prices
- `entry_time` / `close_time`: Signal timestamps
- `raw_profit`: Calculated profit/loss

**UNIQUE constraint**: `(entry_time, signal_type)` - prevents duplicates

### BandsPercentDB
Bollinger Bands Percent data per signal:
- `signal_id` (FK): Links to SignalParamsDB
- `timeframe`: Chart period (e.g., PERIOD_M1, PERIOD_H1)
- `period`: Indicator period (5, 8, 13, etc.)
- `bands_percent_0-3`: BB% values for bars 0-3
- `bands_percent_signal_0-3`: Signal line values
- `bands_percent_slope_0-3`: Slope direction (0=none, 1=up, 2=down)
- `bands_percent_percentil_0-3`: Percentile classification
- `bands_percent_trend_0-3`: Trend identification

### StochasticDB
Stochastic indicator data per signal:
- Similar structure to BandsPercentDB
- `stochastic_0-3`: Main line values
- `stochastic_signal_0-3`: Signal line values
- Slope, percentile, and trend metrics

### StochasticMarketStructureDB
Market structure analysis based on stochastic:
- `first/second/third/fourth_structure_type`: Structure patterns (HH, HL, LH, LL)
- `first/second/third/fourth_structure_time`: Structure timestamps
- `first/second/third/fourth_structure_price`: Structure price levels
- `first/second/third/fourth_fibonacci_level`: Fibonacci retracement levels

## How It Works

### Signal Detection Logic

**Bullish Signal:**
- Detected when Stochastic signal line (bar 1) <= 30 (oversold)
- Records entry at current ASK price
- Stores all indicator data at the moment of detection

**Bearish Signal:**
- Detected when Stochastic signal line (bar 1) >= 70 (overbought)
- Records entry at current BID price
- Stores all indicator data at the moment of detection

### Data Flow

1. **OnInit()**:
   - Initialize database connection
   - Create/verify database tables
   - Load all indicator handles across timeframes
   - Insert dataset record

2. **OnTick()**:
   - Check spread limits (Max_Spread parameter)
   - Verify market is open
   - On new bar: Detect bullish/bearish signals
   - On every tick: Manage open signals (1-minute duration)

3. **Signal Lifecycle**:
   - Detection → Create SignalParams structure
   - Populate indicator data from all timeframes/periods
   - Add to running signals array
   - Monitor for 1 minute duration
   - Close signal and calculate profit
   - Store complete signal transaction to database

4. **OnDeinit()**:
   - Close database connection gracefully

## Installation

1. Place `Market_Scraper_Data_EA.mq5` in your MetaTrader 5 Experts folder:
   ```
   [Terminal_Data]/MQL5/Experts/Market_Scraper_Data/
   ```

2. Ensure all service files are in the correct subdirectories:
   ```
   services/
   ├── frontend/
   ├── trading_database/
   ├── trading_management/
   ├── trading_signals/
   └── trading_tools/
   ```

3. Required custom indicators in `[Terminal_Data]/MQL5/Indicators/Examples/`:
   - `BB_Standard.ex5`
   - `BB_Percent_Standard.ex5`
   - `Stochastic.ex5`
   - `Stochastic_Structure.ex5`

4. Compile the EA in MetaEditor

## Configuration

### Input Parameters

**EA Settings:**
- `EA_License_Key`: License key (optional, for future use)
- `Database_System_Name`: Unique name for this dataset (e.g., "BINARY_XAUUSD")
- `Database_System_Notes`: Description of the data collection strategy

**Account Settings:**
- `Account_Size`: Reference account size (default: 1200)
- `Custom_Magic`: Custom magic number (0 = auto-generate)
- `Max_Spread`: Maximum allowed spread in points (default: 15)
- `Min_Range_Points`: Minimum range in points (default: 15)

**Developer Settings:**
- `Test_Mode`: Reduces indicators loaded for faster testing (default: false)
- `Hide_Indicator_Variants`: Hide indicators from chart (default: true)
- `Enable_Logs`: Enable detailed logging (default: true)

## Usage

1. **Attach to Chart**:
   - Open any chart (symbol will be used for data collection)
   - Drag the EA onto the chart
   - Configure input parameters
   - Enable AutoTrading

2. **Database Location**:
   - SQLite database is created in: `[Terminal_Data]/MQL5/Files/Common/`
   - Filename: `{Database_System_Name}_db.sqlite`

3. **Monitoring**:
   - Chart comment shows: "Enabled/Disabled / Magic: {number}"
   - Check Experts log for indicator loading and signal storage

4. **Data Analysis**:
   - Use SQLite browser tools to query the database
   - Export data for machine learning pipelines
   - Analyze patterns and correlations

## Project Structure

```
Market_Scraper_Data/
├── Market_Scraper_Data_EA.mq5          # Main EA file
├── README.md                            # This file
├── .gitignore                          # Git ignore rules
├── .github/
│   └── copilot-instructions.md         # AI coding guidelines
└── services/                           # Modular services
    ├── frontend/                       # UI components
    │   └── ea_license_light_version.mqh
    ├── trading_database/               # Database operations
    │   ├── initial_database_setup.mqh
    │   └── database_signal_wrapper.mqh
    ├── trading_management/             # Market analysis
    │   ├── indicator_definitions_loader.mqh
    │   └── market_conditions_functions.mqh
    ├── trading_signals/                # Signal detection
    │   ├── market_signal_crawler.mqh
    │   ├── signal_params_struct.mqh
    │   └── tick_signals_manager.mqh
    └── trading_tools/                  # Utility functions
        ├── array_functions.mqh
        ├── base_structures.mqh
        ├── logs_helper.mqh
        ├── miscelaneos.mqh
        ├── money_functions.mqh
        └── signal_enums.mqh
```

## Development Guidelines

### MQL5 Conventions
- **No C++11 features**: No `auto`, lambdas, references, heavy templates
- **Code style**: 2-space indent, `snake_case` variables, `CamelCase` functions
- **Modularity**: One file = one responsibility
- **Include paths**:
  - Standard libraries: `#include <Library/File.mqh>`
  - Custom services: `#include "services/module/file.mqh"`

### Database Best Practices
- Use transactions for multi-table inserts
- Check for existing records before inserting
- Enable WAL mode for concurrent access
- Use prepared statements (via DatabasePrepare)
- Proper error handling with GetLastError()

### Testing Considerations
- MQL5 does not support traditional unit tests
- Test in Strategy Tester with historical data
- Use `Test_Mode` to reduce indicator load during development
- Monitor database file size and growth rate

## Database Queries Examples

### Count Total Signals
```sql
SELECT COUNT(*) FROM SignalParamsDB;
```

### Get Bullish Signals by Symbol
```sql
SELECT sp.*, md.symbol, md.name
FROM SignalParamsDB sp
JOIN MarketDatasetsDB md ON sp.dataset_id = md.dataset_id
WHERE sp.signal_type = 1
AND md.symbol = 'XAUUSD';
```

### Analyze Stochastic at Entry
```sql
SELECT
  sp.entry_time,
  sp.signal_type,
  s.stochastic_0,
  s.stochastic_signal_0,
  sp.raw_profit
FROM SignalParamsDB sp
JOIN StochasticDB s ON sp.signal_id = s.signal_id
WHERE s.timeframe = 1 AND s.period = 13
ORDER BY sp.entry_time DESC;
```

## Troubleshooting

**Issue: EA not detecting signals**
- Check spread is below Max_Spread
- Verify market is open
- Ensure indicators are loaded (check Experts log)

**Issue: Database errors**
- Verify write permissions in Common files folder
- Check disk space availability
- Review GetLastError() output in logs

**Issue: Indicators not loading**
- Confirm custom indicators are compiled (.ex5 files)
- Check indicator paths in indicator_definitions_loader.mqh
- Verify indicator parameters match expected format

## License & Copyright

All rights reserved for Traders Capital Team.
This EA is proprietary software. Unauthorized distribution or modification is prohibited.

For support, contact: @loldlm

---

**Disclaimer**: This EA is designed for data collection purposes. It does not execute actual trades. Use collected data responsibly and ensure compliance with your broker's data usage policies.

