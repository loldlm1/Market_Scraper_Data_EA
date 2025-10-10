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
- Candle body oscillator and momentum data

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

5. **Body MA (Candle Body Oscillator)**
   - Candle body size oscillator
   - Moving average of body sizes
   - Body trend (strong/weak)
   - Body vs MA relationship (bullish/bearish)

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
- `bands_percent_0-3`: BB% values for bars 0-3 (main line)
- `bands_percent_signal_0-3`: Signal line values for bars 0-3
- `bands_percent_slope_0-3`: Slope direction (0=none, 1=up, 2=down)
- `bands_percent_signal_slope_0-3`: Signal line slope direction
- `bands_percent_percentil_0-3`: Percentile classification (0-100 range)
- `bands_percent_signal_percentil_0-3`: Signal line percentile classification
- `bands_percent_trend_0-3`: Trend identification (1=bullish, 2=bearish, 0=none)
- `bb_close_0-3`: Raw BB% values for Close prices (bars 0-3)
- `bb_open_0-3`: Raw BB% values for Open prices (bars 0-3)
- `bb_high_0-3`: Raw BB% values for High prices (bars 0-3)
- `bb_low_0-3`: Raw BB% values for Low prices (bars 0-3)

**PRIMARY KEY**: `(signal_id, timeframe, period)` - ensures one record per signal/timeframe/period combination

**Data Timing**: All `_0` values represent the entry_time candle, `_1` = 1 bar before entry, `_2` = 2 bars before, `_3` = 3 bars before

### StochasticDB
Stochastic indicator data per signal:
- `signal_id` (FK): Links to SignalParamsDB
- `timeframe`: Chart period (e.g., PERIOD_M1, PERIOD_H1)
- `period`: Indicator period (5, 8, 13, etc.)
- `stochastic_0-3`: Main line (%K) values for bars 0-3
- `stochastic_signal_0-3`: Signal line (%D) values for bars 0-3
- `stochastic_slope_0-3`: Main line slope direction (0=none, 1=up, 2=down)
- `stochastic_signal_slope_0-3`: Signal line slope direction
- `stochastic_percentil_0-3`: Percentile classification (0-100 range)
- `stochastic_signal_percentil_0-3`: Signal line percentile classification
- `stochastic_trend_0-3`: Trend identification (1=bullish, 2=bearish, 0=none)

**PRIMARY KEY**: `(signal_id, timeframe, period)` - ensures one record per signal/timeframe/period combination

**Data Timing**: All `_0` values represent the entry_time candle, `_1` = 1 bar before entry, `_2` = 2 bars before, `_3` = 3 bars before

### StochasticMarketStructureDB
Market structure analysis based on stochastic (Summary View):
- `signal_id` (FK): Links to SignalParamsDB
- `timeframe`: Chart period (e.g., PERIOD_M1, PERIOD_H1)
- `period`: Indicator period (5, 8, 13, etc.)
- `first_structure_type` through `six_structure_type`: Structure patterns (0=EQ, 1=HH, 2=HL, 3=LH, 4=LL)
- `first_structure_time` through `fourth_structure_time`: Structure timestamps (epoch seconds)
- `first_structure_price` through `fourth_structure_price`: Structure price levels
- `first_fibonacci_level` through `fourth_fibonacci_level`: Fibonacci retracement levels (0-100 percentage)

**PRIMARY KEY**: `(signal_id, timeframe, period)` - ensures one record per signal/timeframe/period combination

**Note**: This table provides a quick summary view with the first 6 structure types and 4 fibonacci levels for backward compatibility.

### ExtremumStatisticsDB (NEW - v1.10)
Detailed per-extremum analysis with advanced fibonacci statistics:
- `signal_id` (FK): Links to SignalParamsDB
- `timeframe`: Chart period (e.g., PERIOD_M1, PERIOD_H1)
- `period`: Indicator period (5, 8, 13, etc.)
- `extremum_index`: Position in extrema array (0 = most recent)
- `extremum_time`: Timestamp of this extremum (epoch seconds)
- `extremum_price`: Price level of this extremum
- `is_peak`: 1 if peak, 0 if bottom

**EXTREMUM_INTERN Statistics** (Internal Fibonacci Analysis):
- `intern_fibo_level`: Fibonacci % from previous opposite extremum (can be >100%)
- `intern_reference_price`: Reference price used for INTERN calculation
- `intern_is_extension`: 1 if >100% (extended beyond previous swing), 0 otherwise

**EXTREMUM_EXTERN Statistics** (External Fibonacci Analysis):
- `extern_fibo_level`: Fibonacci % from oldest extremum range (typically 0-78.6%)
- `extern_oldest_high`: Highest peak in analyzed history
- `extern_oldest_low`: Lowest bottom in analyzed history
- `extern_structures_broken`: Count of highs/lows exceeded to reach this level
- `extern_is_active`: 1 when INTERN >100% (breakout scenario), 0 otherwise

**Structure Classification**:
- `structure_type`: Dynamic structure pattern (0=EQ, 1=HH, 2=HL, 3=LH, 4=LL)

**PRIMARY KEY**: `(signal_id, timeframe, period, extremum_index)` - one record per extremum

**Data Depth**: Stores up to 13 extrema by default (configurable in code)

**Use Cases**:
- **Trend Strength**: INTERN >150% indicates strong momentum
- **Extension Detection**: INTERN >100% = price extended beyond previous structure
- **Long-term Context**: EXTERN shows position within historical range
- **Breakout Validation**: `extern_structures_broken` counts levels exceeded
- **Support/Resistance**: EXTERN near 0%/100% = key historical levels

**Example Queries** (see Database Queries section below)

### BodyMADB
Candle body oscillator and moving average data per signal:
- `signal_id` (FK): Links to SignalParamsDB
- `timeframe`: Chart period (e.g., PERIOD_M1, PERIOD_H1)
- `period`: Indicator period (always 5 for Body MA)
- `body_value_0-3`: Raw candle body size values for bars 0-3 (abs(close - open))
- `body_ma_0-3`: Moving average of body values for bars 0-3
- `body_trend_0-3`: Body trend classification:
  - `0` = BODY_UNDEFINED (equal values)
  - `1` = STRONG_BODY_TREND (current body > previous body, increasing momentum)
  - `2` = WEAK_BODY_TREND (current body < previous body, decreasing momentum)
- `body_ma_state_0-3`: Body vs MA relationship:
  - `0` = BODY_UNDEFINED_MA (body = MA)
  - `1` = BODY_BULLISH_MA (body > MA, above-average candle size)
  - `2` = BODY_BEARISH_MA (body < MA, below-average candle size)

**PRIMARY KEY**: `(signal_id, timeframe, period)` - ensures one record per signal/timeframe/period combination

**Data Timing**: All `_0` values represent the entry_time candle, `_1` = 1 bar before entry, `_2` = 2 bars before, `_3` = 3 bars before

**Interpretation**:
- Large body values indicate strong directional moves
- Small body values indicate consolidation or indecision
- STRONG_BODY_TREND suggests accelerating momentum
- BODY_BULLISH_MA indicates current candle is larger than average (strong move)
- Useful for filtering noise and identifying genuine breakouts vs. weak moves

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

**Data Timing Logic:**
- `entry_time` is captured at the moment of signal detection (current candle open time)
- All indicator values (`_0`, `_1`, `_2`, `_3`) are fetched based on the entry_time candle, not the current candle
- This ensures historical accuracy: if a signal is logged/stored later, the data still reflects the exact market conditions at entry_time
- The system calculates the correct shift for each timeframe to match the entry_time candle
- Example: If entry_time = 00:03 and we log at 00:04, the system uses shift=1 to get 00:03 data (not shift=0 which would be 00:04)

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
   - `Body_MA.ex5`

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
- `Enable_Verification_Logs`: Enable detailed verification logs for data timing (default: false)

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

### Analyze BB% with Raw OHLC Prices
```sql
SELECT
  sp.entry_time,
  sp.signal_type,
  bp.bands_percent_0,
  bp.bb_close_0,
  bp.bb_open_0,
  bp.bb_high_0,
  bp.bb_low_0,
  sp.raw_profit
FROM SignalParamsDB sp
JOIN BandsPercentDB bp ON sp.signal_id = bp.signal_id
WHERE bp.timeframe = 1 AND bp.period = 21
ORDER BY sp.entry_time DESC;
```

### Analyze Body MA Momentum
```sql
SELECT
  sp.entry_time,
  sp.signal_type,
  bm.body_value_0,
  bm.body_ma_0,
  bm.body_trend_0,
  bm.body_ma_state_0,
  sp.raw_profit
FROM SignalParamsDB sp
JOIN BodyMADB bm ON sp.signal_id = bm.signal_id
WHERE bm.timeframe = 1 AND bm.period = 5
ORDER BY sp.entry_time DESC;
```

### Get Complete Signal Data for Machine Learning
```sql
SELECT
  md.symbol,
  md.name,
  sp.signal_type,
  sp.entry_time,
  sp.entry_price,
  sp.raw_profit,
  bp.bands_percent_0,
  bp.bands_percent_1,
  bp.bands_percent_2,
  bp.bands_percent_3,
  bp.bb_close_0,
  bp.bb_open_0,
  bp.bb_high_0,
  bp.bb_low_0,
  s.stochastic_0,
  s.stochastic_signal_0,
  sm.first_structure_type,
  sm.first_fibonacci_level,
  bm.body_value_0,
  bm.body_ma_0,
  bm.body_trend_0,
  bm.body_ma_state_0
FROM SignalParamsDB sp
JOIN MarketDatasetsDB md ON sp.dataset_id = md.dataset_id
JOIN BandsPercentDB bp ON sp.signal_id = bp.signal_id
JOIN StochasticDB s ON sp.signal_id = s.signal_id
JOIN StochasticMarketStructureDB sm ON sp.signal_id = sm.signal_id
JOIN BodyMADB bm ON sp.signal_id = bm.signal_id
WHERE bp.timeframe = 1 AND bp.period = 21
  AND s.timeframe = 1 AND s.period = 5
  AND sm.timeframe = 1 AND sm.period = 5
  AND bm.timeframe = 1 AND bm.period = 5
ORDER BY sp.entry_time DESC;
```

### Query Extremum Statistics (NEW - v1.10)
```sql
-- Get all extrema for a specific signal
SELECT
  extremum_index,
  datetime(extremum_time, 'unixepoch') as extremum_datetime,
  extremum_price,
  CASE WHEN is_peak = 1 THEN 'Peak' ELSE 'Bottom' END as type,
  intern_fibo_level,
  intern_is_extension,
  extern_fibo_level,
  extern_structures_broken,
  CASE structure_type
    WHEN 0 THEN 'EQ'
    WHEN 1 THEN 'HH'
    WHEN 2 THEN 'HL'
    WHEN 3 THEN 'LH'
    WHEN 4 THEN 'LL'
  END as structure
FROM ExtremumStatisticsDB
WHERE signal_id = 1 AND timeframe = 1 AND period = 5
ORDER BY extremum_index;
```

### Find Strong Extensions (INTERN >150%)
```sql
SELECT
  sp.entry_time,
  sp.signal_type,
  es.extremum_index,
  es.extremum_price,
  es.intern_fibo_level,
  es.extern_structures_broken,
  sp.raw_profit
FROM SignalParamsDB sp
JOIN ExtremumStatisticsDB es ON sp.signal_id = es.signal_id
WHERE es.timeframe = 1 
  AND es.period = 5
  AND es.intern_fibo_level > 150.0
  AND es.intern_is_extension = 1
ORDER BY es.intern_fibo_level DESC;
```

### Analyze Breakout Strength
```sql
SELECT
  sp.entry_time,
  sp.signal_type,
  es.extremum_price,
  es.extern_structures_broken,
  es.extern_fibo_level,
  sp.raw_profit
FROM SignalParamsDB sp
JOIN ExtremumStatisticsDB es ON sp.signal_id = es.signal_id
WHERE es.timeframe = 1 
  AND es.period = 5
  AND es.extern_is_active = 1
  AND es.extern_structures_broken >= 3
ORDER BY es.extern_structures_broken DESC;
```

### Compare Summary vs Detailed View
```sql
-- Get summary from old table
SELECT 
  signal_id,
  first_structure_type,
  second_structure_type,
  first_fibonacci_level
FROM StochasticMarketStructureDB
WHERE signal_id = 1 AND timeframe = 1 AND period = 5;

-- Get detailed extrema from new table
SELECT 
  extremum_index,
  structure_type,
  intern_fibo_level,
  extern_fibo_level
FROM ExtremumStatisticsDB
WHERE signal_id = 1 AND timeframe = 1 AND period = 5
ORDER BY extremum_index;
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

