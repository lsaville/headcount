require_relative 'test_helper'
require_relative '../lib/district_repository'
require 'csv'

class DistrictRepositoryTest < Minitest::Test
  def setup
    @dr = DistrictRepository.new
    @dr.load_data({
      :enrollment => {
        :kindergarten => "./test/fixtures/Kindergartners in full-day program.csv"
      }
    })
  end

  def test_find_by_name
    district = @dr.find_by_name("ACADEMY 20")
    assert_equal "ACADEMY 20", district.name
  end

  def test_find_all_matching
    districts = @dr.find_all_matching("o")
    assert_equal 2, districts.count
  end

  def test_find_all_matching_no_match
    districts = @dr.find_all_matching("aG")
    assert_equal [], districts
  end

  def test_auto_create_enrollment_repo
    assert_equal EnrollmentRepository, @dr.enrollments.class
  end

  def test_a_district_has_an_enrollment
    district = @dr.find_by_name("ACADEMY 20")
    assert_equal 0.436, district.enrollment.kindergarten_participation_in_year(2010)
  end
end
