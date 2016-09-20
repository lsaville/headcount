require_relative 'test_helper'
require_relative '../lib/district'
require 'csv'

class DistrictTest < Minitest::Test

  def test_district_name
    d = District.new({:name => "ACADEMY 20"})
    assert_equal "ACADEMY 20", d.name
  end

end
