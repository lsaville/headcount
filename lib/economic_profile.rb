require_relative 'exceptions'
require_relative 'clean'

class EconomicProfile
  include Clean
  attr_reader :name, :median_household_income, :children_in_poverty,
              :free_or_reduced_price_lunch, :title_i

  def initialize(data)
    @name = data[:name]
    @median_household_income = data[:median_household_income] || {}
    @children_in_poverty = data[:children_in_poverty] || {}
    @free_or_reduced_price_lunch = data[:free_or_reduced_price_lunch] || {}
    @title_i = data[:title_i] || {}
  end

  def median_household_income_in_year(year)
    raise UnknownDataError,
      "Unknown year" unless (2005..2013).to_a.include?(year)
    counter = 0
    sum = 0
    result = @median_household_income.each do |years, income|
      if year.between? years.first, years.last
        sum += income
        counter +=1
      end
    end
    average = sum / counter
  end

  def median_household_income_average
    numerator = @median_household_income.reduce(0) do |sum, (years,income)|
      sum += income
    end
    average = numerator / @median_household_income.count
  end

  def children_in_poverty_in_year(year)
    years = [1995,1997,1999,2000,2001,2002,2003,
             2004,2005,2006,2007,2008,2009,2010,
             2011,2012,2013]
    raise UnknownDataError unless years.include?(year)

    Clean.three_truncate(@children_in_poverty[year])
  end

  def free_or_reduced_price_lunch_percentage_in_year(year)
    raise UnknownDataError unless (2000..2014).to_a.include?(year)
    Clean.three_truncate(@free_or_reduced_price_lunch[year][:percentage])
  end

  def free_or_reduced_price_lunch_number_in_year(year)
    raise UnknownDataError unless (2000..2014).to_a.include?(year)
    @free_or_reduced_price_lunch[year][:total]
  end

  def title_i_in_year(year)
    raise UnknownDataError unless [2009, 2011, 2012, 2013, 2014].include?(year)
    Clean.three_truncate(@title_i[year])
  end
end
