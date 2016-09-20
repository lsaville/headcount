require_relative 'district_repository'
require_relative 'exceptions'

class HeadcountAnalyst
  attr_reader :district_repository, :calculate,
              :kindergarten_participation_against_high_school_graduation

  def initialize(dr)
    @district_repository = dr
  end

  def top_statewide_test_year_over_year_growth(data)
    raise InsufficientInformationError,
      "A grade must be provided to answer this question" if data[:grade] == nil
    raise UnknownDataError,
      "#{data[:grade]} is not a known grade" unless
        data[:grade] == 3 || data[:grade] == 8

    if data[:grade] == 3
      top_statewide_third(data)
    else
      top_statewide_eighth(data)
    end
  end

  def top_statewide_third(data)
    require "pry"; binding.pry
  end

  def top_statewide_eighth(data)
    require "pry"; binding.pry
  end

  def kindergarten_participation_rate_variation(name, against)
    numerator = calculate(name, "kindergarten_participation")
    denominator = calculate(against[:against], "kindergarten_participation")
    variation = (numerator / denominator).round(3)
  end

  def kindergarten_participation_rate_variation_trend(name, against)
    numerator = @district_repository.
      find_by_name(name).enrollment.kindergarten_participation
    denominator = @district_repository.
      find_by_name(against[:against]).enrollment.kindergarten_participation
    variation_trend_calculator(numerator, denominator)
  end

  def kindergarten_participation_against_high_school_graduation(name)
    numerator = kindergarten_participation_rate_variation(name,
      :against => "COLORADO")
    denominator = calculate(name, "high_school_graduation") /
                  calculate("COLORADO", "high_school_graduation")
    variation = (numerator / denominator).round(3)
  end

  def kindergarten_participation_correlates_with_high_school_graduation(name)
    if name.keys[0] == :for
      correlates_for(name[:for])
    elsif name.keys[0] == :across
      correlates_across(name[:across])
    end
  end

  def correlates_for(name)
    name == "STATEWIDE" ? statewide_correlation : districts_correlation(name)
  end

  def correlates_across(districts)
    results = districts.reduce(0) do |sum, district|
      sum += 1 if
      validator(kindergarten_participation_against_high_school_graduation(district))
    end
    return group_validator(results / districts.count)
  end

  def calculate(name, type)
    years = @district_repository.find_by_name(name).enrollment.send(type)
    sum = years.reduce(0) do |sum, (key,value)|
      sum + years[key]
    end
    average = Clean.three_truncate(sum / years.count)
  end

  def variation_trend_calculator(numerator, denominator)
    result = {}
    numerator.each do |key,value|
      result[key] = Clean.three_truncate(numerator[key]/denominator[key])
    end
    result
  end

  def districts_correlation(name)
    variation = kindergarten_participation_against_high_school_graduation(name)
    validator(variation)
  end

  def statewide_correlation
    sum = 0
    @district_repository.districts.each do |key, value|
      sum += 1 if
      validator(kindergarten_participation_against_high_school_graduation(key))
    end
    variation = sum.to_f / @district_repository.districts.count
    group_validator(variation)
  end

  def group_validator(variation)
    variation >= 0.70 ? true : false
  end

  def validator(variation)
    variation >= 0.6 && variation <= 1.5 ? true : false
  end

end
