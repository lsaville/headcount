require_relative "test_helper"
require_relative "../lib/statewide_test"
require_relative "../lib/statewide_test_repository"

class StatewideTestTest < Minitest::Test
  def test_it_exists
    statewide_test = StatewideTest.new("test")
    assert_equal StatewideTest, statewide_test.class
  end

  def test_it_can_hold_data
    statewide_test = StatewideTest.new("test")
    statewide_test.third_grade["something"] = "data"
    assert_equal ({"something" => "data"}), statewide_test.third_grade
  end

  def test_it_can_hold_third_grade
    statewide_test = StatewideTest.new("test")
    year, subject, percentage = "2008", "Math", "0.697"
    statewide_test.third_grade[year] = {subject.downcase.to_sym => percentage}
    assert_equal ({"2008"=>{:math=>"0.697"}}), statewide_test.third_grade
  end

  def setup
    @str = StatewideTestRepository.new
    @str.load_data({
      :statewide_testing => {
        :third_grade => "./test/fixtures/3rd grade students scoring proficient or above on the CSAP_TCAP.csv",
        :eighth_grade => "./test/fixtures/8th grade students scoring proficient or above on the CSAP_TCAP.csv",
        :math => "./test/fixtures/Average proficiency on the CSAP_TCAP by race_ethnicity_ Math.csv",
        :reading => "./test/fixtures/Average proficiency on the CSAP_TCAP by race_ethnicity_ Reading.csv",
        :writing => "./test/fixtures/Average proficiency on the CSAP_TCAP by race_ethnicity_ Writing.csv"
      }
    })
  end

  def test_proficient_by_grade
    data1 = { 2008 => {:math => 0.857, :reading => 0.866, :writing => 0.671},
              2009 => {:math => 0.824, :reading => 0.862, :writing => 0.706},
              2010 => {:math => 0.849, :reading => 0.864, :writing => 0.662},
              2011 => {:math => 0.819, :reading => 0.867, :writing => 0.678},
              2012 => {:math => 0.830, :reading => 0.870, :writing => 0.655},
              2013 => {:math => 0.855, :reading => 0.859, :writing => 0.669},
              2014 => {:math => 0.835, :reading => 0.831, :writing => 0.639}}

    data2 = { 2008=>{:math=>0.64, :reading=>0.843, :writing=>0.734},
              2009=>{:math=>0.656, :reading=>0.825, :writing=>0.701},
              2010=>{:math=>0.672, :reading=>0.863, :writing=>0.754},
              2011=>{:reading=>0.832, :math=>0.653, :writing=>0.746},
              2012=>{:math=>0.682, :writing=>0.738, :reading=>0.834},
              2013=>{:math=>0.661, :reading=>0.853, :writing=>0.751},
              2014=>{:math=>0.685, :reading=>0.827, :writing=>0.748} }

    statewide_test = @str.find_by_name("ACADEMY 20")
    assert_equal data1, statewide_test.proficient_by_grade(3)
    assert_equal data2, statewide_test.proficient_by_grade(8)
  end

  def test_proficient_by_race_or_ethnicity
    data = { 2011 => {math: 0.817, reading: 0.898, writing: 0.827},
             2012 => {math: 0.818, reading: 0.893, writing: 0.808},
             2013 => {math: 0.805, reading: 0.902, writing: 0.811},
             2014 => {math: 0.800, reading: 0.855, writing: 0.789} }
    statewide_test = @str.find_by_name("ACADEMY 20")
    assert_equal data, statewide_test.proficient_by_race_or_ethnicity(:asian)
  end

  def test_proficient_for_subject_by_grade_in_year
    statewide_test = @str.find_by_name("ACADEMY 20")
    assert_equal 0.857, statewide_test.proficient_for_subject_by_grade_in_year(:math, 3, 2008)
    assert_equal 0.827, statewide_test.proficient_for_subject_by_grade_in_year(:reading, 8, 2014)
  end

  def test_proficient_for_subject_by_race_in_year
    statewide_test = @str.find_by_name("ACADEMY 20")
    assert_equal 0.818, statewide_test.proficient_for_subject_by_race_in_year(:math, :asian, 2012)
  end

end
