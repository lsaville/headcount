require_relative 'test_helper'
require_relative '../lib/enrollment'

class EnrollmentTest < Minitest::Test
  def test_enrollment_can_be_created
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal Enrollment, e.class
  end

  def test_it_has_a_name
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal "ACADEMY 20", e.name
  end

  def test_it_has_kindergarten_participation_by_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal ({2010 => 0.391, 2011 => 0.353, 2012 => 0.267}), e.kindergarten_participation_by_year
  end

  def test_it_returns_kindergarten_participation_in_a_given_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}})
    assert_equal 0.391, e.kindergarten_participation_in_year(2010)
  end

  def test_graduation_rate_by_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}, :high_school_graduation => { 2010 => 0.895, 2011 => 0.895, 2012 => 0.88983, 2013 => 0.91373, 2014 => 0.898}})
    result = { 2010 => 0.895, 2011 => 0.895, 2012 => 0.889, 2013 => 0.913, 2014 => 0.898}
    assert_equal result, e.graduation_rate_by_year
  end

  def test_graduation_rate_in_year
    e = Enrollment.new({:name => "ACADEMY 20", :kindergarten_participation => {2010 => 0.3915, 2011 => 0.35356, 2012 => 0.2677}, :high_school_graduation => { 2010 => 0.895, 2011 => 0.895, 2012 => 0.88983, 2013 => 0.91373, 2014 => 0.898}})
    assert_equal 0.895, e.graduation_rate_in_year(2010)
  end
end
