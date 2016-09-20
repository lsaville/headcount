require_relative '../lib/enrollment'
require 'csv'
require_relative './enrollment'
require_relative 'data_extractor'

class EnrollmentRepository
  include DataExtractor
  attr_reader :enrollment
  def initialize
    @enrollments = {}
  end

  def load_data(file_data)
    contents = DataExtractor.extract(file_data, :enrollment)
    contents.each do |key, value|
      normal_machinery(contents[key])      if key == :kindergarten
      high_school_machinery(contents[key]) if key == :high_school_graduation
    end
  end

  def high_school_machinery(high_contents)
    high_contents.each do |row|
      add_high_school_data(row)
    end
  end

  def add_high_school_data(row)
    name, year = row[:location].upcase, row[:timeframe].to_i
    percentage = row[:data].to_f

    @enrollments[name].high_school_graduation[year] = percentage
  end

  def normal_machinery(kinder_contents)
    kinder_contents.each do |row|
      enrollment_existence(row)
    end
  end

  def enrollment_existence(row)
    name, year = row[:location].upcase, row[:timeframe].to_i
    percentage = row[:data].to_f

    add_new_data(name, year, percentage)           if find_by_name(name)
    add_new_enrollment(name, year, percentage) unless find_by_name(name)
  end

  def add_new_enrollment(name, year, percentage)
    @enrollments[name] = create_enrollment(name, year, percentage)
  end

  def add_new_data(name, year, percentage)
    @enrollments[name].kindergarten_participation[year] = percentage
  end

  def create_enrollment(name, year, percentage)
    Enrollment.new({:name => name,
                    :kindergarten_participation => {year => percentage}})
  end

  def find_by_name(name)
    @enrollments[name.upcase]
  end
end
