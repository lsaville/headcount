require_relative 'clean'

class Enrollment
  include Clean
  attr_reader :name, :kindergarten_participation_by_year,
              :kindergarten_participation, :high_school_graduation

  def initialize(hash)
    @name = hash[:name].upcase
    @kindergarten_participation = hash[:kindergarten_participation]
    @high_school_graduation = hash[:high_school_graduation] || {}
  end

  def graduation_rate_by_year
    graduation_rates = @high_school_graduation
    graduation_rates.each do |key, value|
      graduation_rates[key] = Clean.three_truncate(graduation_rates[key])
    end
    graduation_rates
  end

  def graduation_rate_in_year(year)
    @high_school_graduation[year]
  end

  def kindergarten_participation_in_year(year)
    percentage = Clean.three_truncate(kindergarten_participation_by_year[year])
  end

  def kindergarten_participation_by_year
    kinder = @kindergarten_participation
    kinder.each do |key, value|
      kinder[key] = Clean.three_truncate(kinder[key])
    end
    kinder
  end
end
