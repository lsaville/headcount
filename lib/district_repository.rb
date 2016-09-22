require_relative 'district'
require 'csv'
require_relative 'enrollment_repository'
require_relative 'statewide_test_repository'
require_relative 'economic_profile_repository'
require_relative 'data_extractor'


class DistrictRepository
  include DataExtractor
  attr_reader :districts, :enrollments, :statewide_tests, :economic_profiles

  def initialize
    @districts = {}
    @enrollments = {}
    @statewide_tests = {}
    @economic_profiles = {}
  end

  def load_data(file_data)
    load_auxilary(file_data)
    contents = DataExtractor.extract(file_data, :enrollment)
    contents = contents[:kindergarten]
    contents.each do |row|
      district_existence(row[:location])
    end
  end

  def load_auxilary(file_data)
    keys = file_data.keys

    if keys.include?(:enrollment) && keys.include?(:statewide_testing) &&
      keys.include?(:economic_profile)

      create_and_load_enrollments(file_data)
      create_and_load_statewide_tests(file_data)
      create_and_load_economic_profles(file_data)
    elsif keys.include?(:enrollment) && keys.include?(:statewide_testing)
      create_and_load_enrollments(file_data)
      create_and_load_statewide_tests(file_data)
    elsif keys.include?(:enrollment)
      create_and_load_enrollments(file_data)
    end
  end

  def create_and_load_economic_profles(file_data)
    @economic_profiles = EconomicProfileRepository.new
    @economic_profiles.load_data(file_data)
  end

  def create_and_load_enrollments(file_data)
    @enrollments = EnrollmentRepository.new
    @enrollments.load_data(file_data)
  end

  def create_and_load_statewide_tests(file_data)
    @statewide_tests = StatewideTestRepository.new
    @statewide_tests.load_data(file_data)
  end

  def district_existence(name)
    if data_exists?
      data = {name: name, enrollment: @enrollments.find_by_name(name)}
    elsif @economic_profiles.is_a?(Hash)
      data = {name: name, enrollment: @enrollments.find_by_name(name),
              statewide_test: @statewide_tests.find_by_name(name)}
    else
      data = {name: name, enrollment: @enrollments.find_by_name(name),
              statewide_test: @statewide_tests.find_by_name(name),
              economic_profile: @economic_profiles.find_by_name(name)}
    end
    @districts[name.upcase] = District.new(data) unless find_by_name(name)
  end

  def data_exists?
    @statewide_tests.is_a?(Hash) && @economic_profiles.is_a?(Hash)
  end

  def find_by_name(name)
    @districts[name.upcase]
  end

  def find_all_matching(name_fragment)
    @districts.keys.select do |district_name|
      district_name.upcase.include?(name_fragment.upcase)
    end
  end
end
