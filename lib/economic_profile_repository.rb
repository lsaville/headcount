require_relative 'clean'
require_relative 'data_extractor'
require_relative 'economic_profile'

class EconomicProfileRepository
  include Clean
  include DataExtractor

  attr_reader :economic_profiles

  def initialize
    @economic_profiles = {}
  end

  def load_data(file_data)
    contents = DataExtractor.extract(file_data, :economic_profile)
    contents.each do |label, contents|
      contents_control(label, contents)
    end
  end

  def find_by_name(name)
    @economic_profiles[name.upcase]
  end

  def contents_control(label, contents)
    case label
    when :median_household_income
      median_income(contents)
    when :children_in_poverty
      child_poverty(contents)
    when :free_or_reduced_price_lunch
      cheap_lunch(contents)
    when :title_i
      title_i(contents)
    end
  end

  def title_i(contents)
    contents.each do |row|
      add_title_i(row)
    end
  end

  def add_title_i(row)
    name, year = row[:location], row[:timeframe].to_i
    percentage = Clean.percentage(row[:data])
    find_by_name(name).title_i[year] = percentage
  end

  def cheap_lunch(contents)
    contents.each do |row|
      if row[:poverty_level] == "Eligible for Free or Reduced Lunch"
        add_lunch_data(row)
      end
    end
  end

  def add_lunch_data(row)
    if row[:dataformat] == "Percent"
      add_lunch_percent(row)
    else
      add_lunch_number(row)
    end
  end

  def add_lunch_percent(row)
    name, year = row[:location], row[:timeframe].to_i
    percentage = row[:data].to_f
    economic_profile = find_by_name(name).free_or_reduced_price_lunch

    if economic_profile.keys.include?(year)
      economic_profile[year][:percentage] = percentage
    else
      economic_profile[year] = {:percentage => percentage}
    end
  end

  def add_lunch_number(row)
    name, year = row[:location], row[:timeframe].to_i
    total = row[:data].to_i
    economic_profile = find_by_name(name).free_or_reduced_price_lunch

    if economic_profile.keys.include?(year)
      economic_profile[year][:total] = total
    else
      economic_profile[year] = {:total => total}
    end
  end

  def child_poverty(contents)
    contents.each do |row|
      add_poverty_data(row) if row[:dataformat] == "Percent"
    end
  end

  def add_poverty_data(row)
    name, year = row[:location].upcase, row[:timeframe].to_i
    percentage = row[:data].to_f
    find_by_name(name).children_in_poverty[year] = percentage
  end

  def median_income(contents)
    contents.each do |row|
      economic_profile_existence(row)
    end
  end

  def economic_profile_existence(row)
    name, median_income = row[:location].upcase, row[:data].to_i
    years = Clean.timeframe(row[:timeframe])

    new_median_data(name, years, median_income)      if find_by_name(name)
    new_economic_profile(name, years, median_income) unless find_by_name(name)
  end

  def new_economic_profile(name, years, median_income)
    @economic_profiles[name] = EconomicProfile.new({name: name})
    @economic_profiles[name].median_household_income[years] = median_income
  end

  def new_median_data(name, years, median_income)
    @economic_profiles[name].median_household_income[years] = median_income
  end
end
