//+------------------------------------------------------------------+
//|           microservices/indicators/fibonacci_calculator.mqh      |
//+------------------------------------------------------------------+
#ifndef _MICROSERVICES_INDICATORS_FIBONACCI_CALCULATOR_MQH_
#define _MICROSERVICES_INDICATORS_FIBONACCI_CALCULATOR_MQH_

#include "../utils/miscellaneous.mqh"
#include "extrema_detector.mqh"
#include "structure_classifier.mqh"

// Estructura de precios para niveles de Fibonacci
struct FibonacciLevelPrices
{
  double entry_level;       // precio del nivel de entrada calculado
  double entry_next_level;  // precio del siguiente nivel (para TP/gestión)

  // DEFAULT CONSTRUCTOR
  FibonacciLevelPrices()
  {
    entry_level      = 0.0;
    entry_next_level = 0.0;
  }

  // COPY CONSTRUCTOR
  FibonacciLevelPrices(const FibonacciLevelPrices &other)
  {
    entry_level      = other.entry_level;
    entry_next_level = other.entry_next_level;
  }
};

//+------------------------------------------------------------------+
//| LEVEL MAPPING: Find precise Fibonacci entry level               |
//| Uses AllFibonacciLevels for backward compatibility              |
//+------------------------------------------------------------------+
double GetPreciseEntryLevel(double entry_level, double &next_level)
{
  int    fibonacci_levels_total = ArraySize(AllFibonacciLevels)-1;
  double entry_level_plus       = 0;

  for(int i = 0; i < fibonacci_levels_total; i++)
  {
    entry_level_plus = NormalizeDouble(entry_level + 1.0, 1); // ADD A +1 TO COVER INCORRECT DECIMAL ENTRY LEVELS

    if(entry_level_plus >= AllFibonacciLevels[i] && entry_level_plus < AllFibonacciLevels[i+1])
    {
      next_level = AllFibonacciLevels[i+1];
      return AllFibonacciLevels[i];
    }
  }

  return entry_level;
}

//+------------------------------------------------------------------+
//| LEVEL MAPPING: Find precise Fibonacci entry level (Default Set) |
//| Uses DefaultFibonacciLevels for ExtremumStatistics              |
//+------------------------------------------------------------------+
double GetPreciseEntryLevelDefault(double entry_level, double &next_level)
{
  int    fibonacci_levels_total = ArraySize(DefaultFibonacciLevels)-1;
  double entry_level_plus       = 0;

  for(int i = 0; i < fibonacci_levels_total; i++)
  {
    entry_level_plus = NormalizeDouble(entry_level + 1.0, 1); // ADD A +1 TO COVER INCORRECT DECIMAL ENTRY LEVELS

    if(entry_level_plus >= DefaultFibonacciLevels[i] && entry_level_plus < DefaultFibonacciLevels[i+1])
    {
      next_level = DefaultFibonacciLevels[i+1];
      return DefaultFibonacciLevels[i];
    }
  }

  return entry_level;
}

//+------------------------------------------------------------------+
//| RETRACEMENT: Calculate Fibonacci retracement from bottom         |
//+------------------------------------------------------------------+
double GetFiboRetracementBottomPrice(double peak_price, double bottom_price, double percentage)
{
  double diff_prices      = peak_price - bottom_price;
  double percentage_price = peak_price - ((percentage / 100.0) * diff_prices);

  return NormalizeDouble(percentage_price, _Digits);
}

//+------------------------------------------------------------------+
//| RETRACEMENT: Calculate Fibonacci retracement from peak           |
//+------------------------------------------------------------------+
double GetFiboRetracementPeakPrice(double peak_price, double bottom_price, double percentage)
{
  double diff_prices      = peak_price - bottom_price;
  double percentage_price = bottom_price + ((percentage / 100.0) * diff_prices);

  return NormalizeDouble(percentage_price, _Digits);
}

//+------------------------------------------------------------------+
//| TREND: Calculate Fibonacci trend price from bottom               |
//+------------------------------------------------------------------+
double GetFiboTrendBottomPrice(double peak_price, double bottom_price, double percentage)
{
  double diff_prices      = peak_price - bottom_price;
  double percentage_price = peak_price - ((percentage / 100.0) * diff_prices); // 0% IS THE PEAK

  return NormalizeDouble(percentage_price, _Digits);
}

//+------------------------------------------------------------------+
//| TREND: Calculate Fibonacci trend price from peak                 |
//+------------------------------------------------------------------+
double GetFiboTrendPeakPrice(double peak_price, double bottom_price, double percentage)
{
  double diff_prices      = peak_price - bottom_price;
  double percentage_price = ((percentage / 100.0) * diff_prices) + bottom_price; // 0% IS THE BOTTOM

  return NormalizeDouble(percentage_price, _Digits);
}

//+------------------------------------------------------------------+
//| TREND: Calculate Fibonacci trend percentage from peak            |
//+------------------------------------------------------------------+
double GetFiboTrendPeakPercent(double peak_price, double bottom_price, double price)
{
  double percentage = ((price - bottom_price) / (peak_price - bottom_price)) * 100.0; // 100% IS THE PEAK

  return NormalizeDouble(percentage, 1);
}

//+------------------------------------------------------------------+
//| TREND: Calculate Fibonacci trend percentage from bottom          |
//+------------------------------------------------------------------+
double GetFiboTrendBottomPercent(double peak_price, double bottom_price, double price)
{
  double percentage = ((peak_price - price) / (peak_price - bottom_price)) * 100.0; // 100% IS THE BOTTOM

  return NormalizeDouble(percentage, 1);
}

//+------------------------------------------------------------------+
//| EXPANSION: Calculate Fibonacci expansion price from bottom       |
//+------------------------------------------------------------------+
double GetFETrendBottomPrice(double peak_price, double bottom_price, double correction_peak_hh, double percentage)
{
  double diff_prices      = peak_price - bottom_price; // A -> B
  double percentage_price = correction_peak_hh - ((percentage / 100.0) * diff_prices); // SUBSTRACT (C) PEAK HH

  return NormalizeDouble(percentage_price, _Digits);
}

//+------------------------------------------------------------------+
//| EXPANSION: Calculate Fibonacci expansion price from peak         |
//+------------------------------------------------------------------+
double GetFETrendPeakPrice(double peak_price, double bottom_price, double correction_bottom_ll, double percentage)
{
  double diff_prices      = peak_price - bottom_price; // B -> A
  double percentage_price = correction_bottom_ll + ((percentage / 100.0) * diff_prices); // PLUS (C) BOTTOM LL

  return NormalizeDouble(percentage_price, _Digits);
}

//+------------------------------------------------------------------+
//| EXPANSION: Calculate Fibonacci expansion percentage from bottom  |
//+------------------------------------------------------------------+
double GetFETrendBottomPercentage(double peak_price, double bottom_price, double correction_peak_hh, double price)
{
  double diff_prices = peak_price - bottom_price;  // Movimiento A -> B
  double percentage  = ((correction_peak_hh - price) / diff_prices) * 100.0; // PEAK PRICE (C) IS 0%

  return NormalizeDouble(percentage, 1);
}

//+------------------------------------------------------------------+
//| EXPANSION: Calculate Fibonacci expansion percentage from peak    |
//+------------------------------------------------------------------+
double GetFETrendPeakPercentage(double peak_price, double bottom_price, double correction_bottom_ll, double price)
{
  double diff_prices = peak_price - bottom_price;  // Movimiento B -> A
  double percentage  = ((price - correction_bottom_ll) / diff_prices) * 100.0; // BOTTOM PRICE (C) IS 0%

  return NormalizeDouble(percentage, 1);
}

//+------------------------------------------------------------------+
//| HELPER: Calculate bullish Fibonacci percentage and level         |
//| Pattern: FIRST LOW -> FIRST HIGH -> SECOND LOW                   |
//+------------------------------------------------------------------+
double GetBullishFibonacciPercentage(double signal_entry_bottom_price, double signal_peak_price, double signal_bottom_price)
{
  FibonacciLevelPrices fibonacci_prices;
  double fibonacci_percentage = GetFiboTrendBottomPercent(signal_peak_price, signal_bottom_price, signal_entry_bottom_price);

  double next_level = 0;
  fibonacci_prices.entry_level      = GetPreciseEntryLevel(fibonacci_percentage, next_level);
  fibonacci_prices.entry_next_level = next_level;

  return fibonacci_prices.entry_level;
}

//+------------------------------------------------------------------+
//| HELPER: Calculate bearish Fibonacci percentage and level         |
//| Pattern: FIRST HIGH -> FIRST LOW -> SECOND HIGH                  |
//+------------------------------------------------------------------+
double GetBearishFibonacciPercentage(double signal_entry_peak_price, double signal_bottom_price, double signal_peak_price)
{
  FibonacciLevelPrices fibonacci_prices;
  double fibonacci_percentage = GetFiboTrendPeakPercent(signal_peak_price, signal_bottom_price, signal_entry_peak_price);

  double next_level = 0;
  fibonacci_prices.entry_level      = GetPreciseEntryLevel(fibonacci_percentage, next_level);
  fibonacci_prices.entry_next_level = next_level;

  return fibonacci_prices.entry_level;
}

//+------------------------------------------------------------------+
//| Calculate all 4 Fibonacci levels from extrema array              |
//+------------------------------------------------------------------+
void CalculateFibonacciLevels(
  const OscillatorMarketStructure &extrema[],
  bool initial_is_bottom,
  bool initial_is_peak,
  double &fibonacci_levels[]
) {
  ArrayResize(fibonacci_levels, 4);

  // índices base para cálculos
  int structure_peaks_index   = initial_is_bottom ? 1 : 0;
  int structure_bottoms_index = initial_is_peak   ? 1 : 0;

  // FIBONACCI LEVELS
  if(initial_is_bottom)
  {
    fibonacci_levels[0] = GetBullishFibonacciPercentage(extrema[structure_bottoms_index].extremum_low,    extrema[structure_bottoms_index+1].extremum_high, extrema[structure_bottoms_index+2].extremum_low);
    fibonacci_levels[1] = GetBearishFibonacciPercentage(extrema[structure_bottoms_index+1].extremum_high, extrema[structure_bottoms_index+2].extremum_low,  extrema[structure_bottoms_index+3].extremum_high);
    fibonacci_levels[2] = GetBullishFibonacciPercentage(extrema[structure_bottoms_index+2].extremum_low,  extrema[structure_bottoms_index+3].extremum_high, extrema[structure_bottoms_index+4].extremum_low);
    fibonacci_levels[3] = GetBearishFibonacciPercentage(extrema[structure_bottoms_index+3].extremum_high, extrema[structure_bottoms_index+4].extremum_low,  extrema[structure_bottoms_index+5].extremum_high);
  }

  if(initial_is_peak)
  {
    fibonacci_levels[0] = GetBearishFibonacciPercentage(extrema[structure_peaks_index].extremum_high,    extrema[structure_peaks_index+1].extremum_low,  extrema[structure_peaks_index+2].extremum_high);
    fibonacci_levels[1] = GetBullishFibonacciPercentage(extrema[structure_peaks_index+1].extremum_low,   extrema[structure_peaks_index+2].extremum_high, extrema[structure_peaks_index+3].extremum_low);
    fibonacci_levels[2] = GetBearishFibonacciPercentage(extrema[structure_peaks_index+2].extremum_high,  extrema[structure_peaks_index+3].extremum_low,  extrema[structure_peaks_index+4].extremum_high);
    fibonacci_levels[3] = GetBullishFibonacciPercentage(extrema[structure_peaks_index+3].extremum_low,   extrema[structure_peaks_index+4].extremum_high, extrema[structure_peaks_index+5].extremum_low);
  }
}

#endif // _MICROSERVICES_INDICATORS_FIBONACCI_CALCULATOR_MQH_
