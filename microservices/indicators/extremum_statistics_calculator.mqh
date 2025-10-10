//+------------------------------------------------------------------+
//|      microservices/indicators/extremum_statistics_calculator.mqh |
//+------------------------------------------------------------------+
#ifndef _MICROSERVICES_INDICATORS_EXTREMUM_STATISTICS_CALCULATOR_MQH_
#define _MICROSERVICES_INDICATORS_EXTREMUM_STATISTICS_CALCULATOR_MQH_

#include "extrema_detector.mqh"
#include "structure_classifier.mqh"
#include "fibonacci_calculator.mqh"

//+------------------------------------------------------------------+
//| Calculate internal fibonacci for single extremum                 |
//| Returns percentage from previous opposite extremum               |
//+------------------------------------------------------------------+
double CalculateExtremumIntern(
  OscillatorMarketStructure &current,
  OscillatorMarketStructure &previous_opposite,
  bool current_is_peak
) {
  double current_price = current_is_peak ? current.extremum_high : current.extremum_low;
  double reference_price = current_is_peak ? previous_opposite.extremum_low : previous_opposite.extremum_high;
  
  if(current_is_peak)
  {
    // Peak: calculate percentage from bottom to peak
    // Can be > 100% if extended beyond previous peak
    return GetFiboTrendPeakPercent(current_price, reference_price, current_price);
  }
  else
  {
    // Bottom: calculate percentage from peak to bottom
    // Can be > 100% if extended beyond previous bottom
    return GetFiboTrendBottomPercent(current_price, reference_price, current_price);
  }
}

//+------------------------------------------------------------------+
//| Count structures broken to reach current level                   |
//+------------------------------------------------------------------+
int CountStructuresBroken(
  OscillatorMarketStructure &extrema_array[],
  int current_index,
  int reference_index,
  bool is_peak
) {
  if(reference_index < 0) return 0;
  
  int broken_count = 0;
  double current_price = is_peak ? extrema_array[current_index].extremum_high : extrema_array[current_index].extremum_low;
  
  // Count same-type extrema BETWEEN current and reference that were broken
  for(int i = current_index + 1; i <= reference_index; i++)
  {
    if(extrema_array[i].is_peak == is_peak)
    {
      double compare_price = is_peak ? extrema_array[i].extremum_high : extrema_array[i].extremum_low;
      
      if(is_peak)
      {
        // For peaks: count intermediate peaks lower than current (broken through)
        if(current_price > compare_price) broken_count++;
      }
      else
      {
        // For bottoms: count intermediate bottoms higher than current (broken through)
        if(current_price < compare_price) broken_count++;
      }
    }
  }
  
  return broken_count;
}

//+------------------------------------------------------------------+
//| Calculate external fibonacci for single extremum                 |
//| Uses the same reference structure that INTERN identified          |
//+------------------------------------------------------------------+
void CalculateExtremumExtern(
  OscillatorMarketStructure &extrema_array[],
  int current_index,
  int prev_same_type_index,
  int prev_opposite_index,
  ExtremumStatistics &stats
) {
  if(prev_same_type_index < 0 || prev_opposite_index < 0) return;
  
  bool is_peak = extrema_array[current_index].is_peak;
  double current_price = is_peak ? extrema_array[current_index].extremum_high : extrema_array[current_index].extremum_low;
  
  // EXTERN uses the SAME reference structure that INTERN identified:
  // - prev_same_type_index = the old peak/bottom being tested (100% mark)
  // - Find the swing opposite between current and that reference (0% mark)
  
  int    reference_index = prev_same_type_index;
  double reference_extreme = 0.0;  // 100% level
  double reference_opposite = 0.0; // 0% level
  
  if(is_peak)
  {
    // For peak: prev_same_type_index is the old peak being tested
    reference_extreme = extrema_array[prev_same_type_index].extremum_high;
    
    // Find the lowest bottom between current and that old peak
    double lowest_bottom = DBL_MAX;
    for(int i = current_index; i <= prev_same_type_index; i++)
    {
      if(!extrema_array[i].is_peak && extrema_array[i].extremum_low < lowest_bottom)
      {
        lowest_bottom = extrema_array[i].extremum_low;
      }
    }
    reference_opposite = lowest_bottom;
    
    stats.extern_oldest_high = reference_extreme;
    stats.extern_oldest_low  = reference_opposite;
  }
  else
  {
    // For bottom: prev_same_type_index is the old bottom being tested
    reference_extreme = extrema_array[prev_same_type_index].extremum_low;
    
    // Find the highest peak between current and that old bottom
    double highest_peak = -DBL_MAX;
    for(int i = current_index; i <= prev_same_type_index; i++)
    {
      if(extrema_array[i].is_peak && extrema_array[i].extremum_high > highest_peak)
      {
        highest_peak = extrema_array[i].extremum_high;
      }
    }
    reference_opposite = highest_peak;
    
    stats.extern_oldest_high = reference_opposite;
    stats.extern_oldest_low  = reference_extreme;
  }
  
  // Calculate fibonacci level if we have valid range
  if(stats.extern_oldest_high > stats.extern_oldest_low)
  {
    stats.extern_fibo_level = GetFiboTrendPeakPercent(stats.extern_oldest_high, stats.extern_oldest_low, current_price);
    
    // Snap to nearest DefaultFibonacciLevel
    double next_level = 0;
    stats.extern_fibo_level = GetPreciseEntryLevelDefault(stats.extern_fibo_level, next_level);
  }
  
  // Count structures broken between current and reference
  stats.extern_structures_broken = CountStructuresBroken(
    extrema_array,
    current_index,
    reference_index,
    is_peak
  );
}

//+------------------------------------------------------------------+
//| Main calculator - populates entire stats array                   |
//+------------------------------------------------------------------+
void CalculateAllExtremumStatistics(
  OscillatorMarketStructure &extrema_array[],
  ExtremumStatistics &stats_array[]
) {
  int array_size = ArraySize(extrema_array);
  
  if(array_size < 2)
  {
    ArrayResize(stats_array, 0);
    return;
  }
  
  // First classify all structure types
  ClassifyAllStructureTypes(extrema_array, stats_array);
  
  // Calculate EXTREMUM_INTERN for each extremum
  // INTERN measures: from previous opposite extremum to current, relative to previous same-type extremum
  for(int i = 0; i < array_size; i++)
  {
    bool current_is_peak = extrema_array[i].is_peak;
    
    // Find previous opposite extremum (immediately before current)
    int prev_opposite_index = -1;
    int prev_same_type_index = -1;
    
    for(int j = i + 1; j < array_size; j++)
    {
      if(extrema_array[j].is_peak != current_is_peak && prev_opposite_index == -1)
      {
        prev_opposite_index = j;
      }
      else if(extrema_array[j].is_peak == current_is_peak && prev_same_type_index == -1)
      {
        prev_same_type_index = j;
        break; // Found both, can stop
      }
    }
    
    // Need at least previous opposite extremum to calculate INTERN
    if(prev_opposite_index >= 0)
    {
      double current_price = current_is_peak ? extrema_array[i].extremum_high : extrema_array[i].extremum_low;
      double reference_price = current_is_peak ? extrema_array[prev_opposite_index].extremum_low : extrema_array[prev_opposite_index].extremum_high;
      
      stats_array[i].intern_reference_price = reference_price;
      
      if(current_is_peak)
      {
        // For Peak: measure from previous bottom (0%) to current peak
        // If we have previous peak, that's the 100% mark
        double prev_peak_price = (prev_same_type_index >= 0) ? extrema_array[prev_same_type_index].extremum_high : current_price;
        
        // Calculate percentage: current position from bottom relative to (previous peak - bottom) range
        if(prev_peak_price > reference_price)
        {
          stats_array[i].intern_fibo_level = ((current_price - reference_price) / (prev_peak_price - reference_price)) * 100.0;
        }
        else
        {
          stats_array[i].intern_fibo_level = 100.0; // Default if no valid range
        }
      }
      else
      {
        // For Bottom: measure from previous peak (0%) to current bottom  
        // If we have previous bottom, that's the 100% mark
        double prev_bottom_price = (prev_same_type_index >= 0) ? extrema_array[prev_same_type_index].extremum_low : current_price;
        
        // Calculate percentage: current position from peak relative to (peak - previous bottom) range
        if(reference_price > prev_bottom_price)
        {
          stats_array[i].intern_fibo_level = ((reference_price - current_price) / (reference_price - prev_bottom_price)) * 100.0;
        }
        else
        {
          stats_array[i].intern_fibo_level = 100.0; // Default if no valid range
        }
      }
      
      // Snap to nearest DefaultFibonacciLevel and normalize
      double next_level = 0;
      stats_array[i].intern_fibo_level = GetPreciseEntryLevelDefault(stats_array[i].intern_fibo_level, next_level);
      
      // Check if extension (>100%)
      stats_array[i].intern_is_extension = (stats_array[i].intern_fibo_level > 100.0);
      
      // EXTERN is active when INTERN >= 61.8% (reaching toward old structure levels)
      // This includes retests (100%) and extensions (>100%)
      stats_array[i].extern_is_active = (stats_array[i].intern_fibo_level >= 61.8);
      
      // Calculate EXTERN using the same reference structure as INTERN
      if(stats_array[i].extern_is_active)
      {
        CalculateExtremumExtern(
          extrema_array,
          i,
          prev_same_type_index,
          prev_opposite_index,
          stats_array[i]
        );
      }
    }
  }
}

#endif // _MICROSERVICES_INDICATORS_EXTREMUM_STATISTICS_CALCULATOR_MQH_

