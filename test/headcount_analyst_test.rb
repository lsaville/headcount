require_relative 'test_helper'
require_relative '../lib/enrollment'
require 'csv'
require_relative '../lib/district_repository'
require_relative '../lib/headcount_analyst'

class HeadcountAnalystTest < Minitest::Test
  attr_reader :ha
  def setup
    dr = DistrictRepository.new
    dr.load_data({
      :enrollment => {
        :kindergarten => "./data/Kindergartners in full-day program.csv",
        :high_school_graduation => "./data/High school graduation rates.csv"
      },
      :statewide_testing => {
        :third_grade => "./data/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./data/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./data/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      },
    })
    @ha = HeadcountAnalyst.new(dr)
  end

  def test_it_holds_a_dr
    assert_equal DistrictRepository, ha.district_repository.class
  end

  def test_it_can_access_enrollment_data
    district = ha.district_repository.find_by_name("ACADEMY 20")
    assert_equal 0.436, district.enrollment.kindergarten_participation_in_year(2010)
  end

  def test_kindergarten_participation_rate_variation
    assert_equal 0.766, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'COLORADO')
  end

  def test_kindergarten_participation_rate_variation_other_district
    assert_equal 0.447, ha.kindergarten_participation_rate_variation('ACADEMY 20', :against => 'YUMA SCHOOL DISTRICT 1')
  end

  def test_calculate
    assert_equal 0.406, ha.calculate("ACADEMY 20", "kindergarten_participation")
    assert_equal 0.898, ha.calculate("ACADEMY 20", "high_school_graduation")
    assert_equal 0.751, ha.calculate("COLORADO", "high_school_graduation")
  end

  def test_kindergarten_participation_rate_variation_trend
    result = {2004 => 1.257, 2005 => 0.96, 2006 => 1.05, 2007 => 0.992, 2008 => 0.717, 2009 => 0.652, 2010 => 0.681, 2011 => 0.727, 2012 => 0.688, 2013 => 0.694, 2014 => 0.661}
    assert_equal result, ha.kindergarten_participation_rate_variation_trend('ACADEMY 20', :against => 'COLORADO')
  end

  def test_variation_trend_calculator
    numerator = {2007=>0.39159, 2006=>0.35364, 2005=>0.26709, 2004=>0.30201, 2008=>0.38456, 2009=>0.39, 2010=>0.43628, 2011=>0.489, 2012=>0.47883, 2013=>0.48774, 2014=>0.49022}
    denominator = {2007=>0.39465, 2006=>0.33677, 2005=>0.27807, 2004=>0.24014, 2008=>0.5357, 2009=>0.598, 2010=>0.64019, 2011=>0.672, 2012=>0.695, 2013=>0.70263, 2014=>0.74118}
    result = {2004 => 1.257, 2005 => 0.96, 2006 => 1.05, 2007 => 0.992, 2008 => 0.717, 2009 => 0.652, 2010 => 0.681, 2011 => 0.727, 2012 => 0.688, 2013 => 0.694, 2014 => 0.661}
    assert_equal result, ha.variation_trend_calculator(numerator, denominator)
  end

  def test_kindergarten_participation_against_high_school_graduation
    assert_equal 0.641, ha.kindergarten_participation_against_high_school_graduation("ACADEMY 20")
    assert_equal 0.548, ha.kindergarten_participation_against_high_school_graduation('MONTROSE COUNTY RE-1J')
    assert_equal 0.801, ha.kindergarten_participation_against_high_school_graduation('STEAMBOAT SPRINGS RE-2')
  end


  def test_validator
    assert ha.validator(0.6)
    assert ha.validator(1.5)
    assert ha.validator(1.0)
    refute ha.validator(0.5)
    refute ha.validator(1.6)
  end

  def test_group_validator
    assert ha.group_validator(0.71)
    refute ha.group_validator(0.22)
  end

  def test_kindergarten_participation_correlates_with_high_school_graduation
    assert_equal true, ha.kindergarten_participation_correlates_with_high_school_graduation(for: 'ACADEMY 20')
  end

  def test_districts_correlation
    assert_equal true, ha.districts_correlation("ACADEMY 20")
  end

  def test_correlation_statewide
    refute ha.kindergarten_participation_correlates_with_high_school_graduation(:for => 'STATEWIDE')
  end

  def test_correlation_across
    districts = ["ACADEMY 20", 'PARK (ESTES PARK) R-3', 'YUMA SCHOOL DISTRICT 1']
    assert ha.kindergarten_participation_correlates_with_high_school_graduation(:across => districts)
  end

  def test_top_error_gate
    assert_raises(UnknownDataError) do
      ha.top_statewide_test_year_over_year_growth(grade: 13, subject: :math)
    end

    assert_raises(InsufficientInformationError) do
      ha.top_statewide_test_year_over_year_growth(subject: :math)
    end
  end

  def test_top_with_grade_subject
    assert_equal ['PRIMERO REORGANIZED 2', 0.625], ha.top_statewide_test_year_over_year_growth(grade: 3, subject: :math)
    assert_equal ["OURAY R-1", 0.242], ha.top_statewide_test_year_over_year_growth(grade: 8, subject: :math)
    assert_equal ["DE BEQUE 49JT", 0.17], ha.top_statewide_test_year_over_year_growth(grade: 8, subject: :writing)
  end

  def test_top_with_grade_subject_and_top
    assert_equal [["DE BEQUE 49JT", 0.17], ["LA VETA RE-2", 0.123], ["OTIS R-3", 0.099]], ha.top_statewide_test_year_over_year_growth(grade: 8, top: 3, subject: :writing)
    assert_equal [["DE BEQUE 49JT", 0.17], ["LA VETA RE-2", 0.123], ["OTIS R-3", 0.099], ["AKRON R-1", 0.075]], ha.top_statewide_test_year_over_year_growth(grade: 8, top: 4, subject: :writing)
  end

end
