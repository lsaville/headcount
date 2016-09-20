require_relative 'test_helper'
require_relative '../lib/economic_profile_repository'

class EconomicProfileRepositoryTest < MiniTest::Test
  def setup
    @epr = EconomicProfileRepository.new
    @epr.load_data({
        :economic_profile => {
          :median_household_income => "./data/Median household income.csv",
          :children_in_poverty => "./data/School-aged children in poverty.csv",
          :free_or_reduced_price_lunch => "./data/Students qualifying for free or reduced price lunch.csv",
          :title_i => "./data/Title I students.csv"
          }})
  end

  def test_it_exists
    assert_instance_of EconomicProfileRepository, @epr
  end

  def test_loading_median
    data = {[2005, 2009]=>56222, [2006, 2010]=>56456, [2008, 2012]=>58244, [2007, 2011]=>57685, [2009, 2013]=>58433}
    assert_equal data, @epr.economic_profiles["COLORADO"].median_household_income
  end

  def test_new_economic_profile
    @epr.new_economic_profile("LEE COUNTY", [2989, 3000], 900000)
    assert_equal 900000, @epr.find_by_name("Lee County").median_household_income[[2989, 3000]]
  end

  def test_new_median_data
    @epr.new_economic_profile("LEE COUNTY", [2989, 3000], 900000)
    @epr.new_median_data("LEE COUNTY", [3002, 5554], 999999)
    data = {[2989, 3000]=>900000, [3002, 5554]=>999999}
    assert_equal data, @epr.find_by_name("lee county").median_household_income
  end
end
