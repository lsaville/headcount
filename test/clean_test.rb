require_relative 'test_helper'
require_relative '../lib/clean'

class CleanerTest < Minitest::Test
  include Clean

  def test_three_truncate
    assert_equal 0.987, Clean.three_truncate(0.98735353)
    assert_equal 0.987, Clean.three_truncate(0.987654)
  end

  def test_three_round
    assert_equal 0.988, Clean.three_round(0.987654)
    refute_equal 0.987, Clean.three_round(0.9877442)
    assert_equal "N/A", Clean.three_round("N/A")
  end

  def test_race_ethnicity
    assert_equal :pacific_islander, Clean.race_ethnicity("Hawaiian/Pacific Islander")
    assert_equal :all_students, Clean.race_ethnicity("All Students")
    assert_equal :two_or_more, Clean.race_ethnicity("Two or More")
    assert_equal :asian, Clean.race_ethnicity("Asian")
  end

  def test_percentage
    assert_equal "N/A", Clean.percentage("N/A")
    assert_equal "N/A", Clean.percentage("LNE")
    assert_equal 0.457, Clean.percentage("0.457")
  end

end
