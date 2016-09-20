require_relative 'exceptions'
class StatewideTest
  attr_reader :third_grade, :eighth_grade, :race_ethnicity_data, :races
  def initialize(name)
    @name         = name
    @third_grade  = {}
    @eighth_grade = {}
    @race_ethnicity_data = {}
    @races = [:asian, :black, :pacific_islander, :hispanic, :native_american,
              :all_students, :two_or_more, :white]
  end

  def proficient_by_grade(grade)
    raise UnknownDataError, "Invalid data" unless [3,8].include?(grade)
    if grade == 3
      third_grade_polish
    elsif grade == 8
      eighth_grade_polish
    end
  end

  def third_grade_polish
    third_grade = @third_grade.each do |year, data|
      data.each do |subject, percentage|
        data[subject] = Clean.three_round(percentage)
      end
    end
    third_grade
  end

  def eighth_grade_polish
    eighth_grade = @eighth_grade.each do |year, data|
      data.each do |subject, percentage|
        data[subject] = Clean.three_round(percentage)
      end
    end
    eighth_grade
  end

  def proficient_by_race_or_ethnicity(race)
    raise UnknownRaceError, "Unknown race" unless races.include?(race)
    race_data = @race_ethnicity_data[race].each do |year, data|
      data.each do |subject, percentage|
        data[subject] = Clean.three_round(percentage)
      end
    end
    race_data
  end

  def proficient_for_subject_by_grade_in_year(subject, grade, year)
    raise UnknownDataError,
      "Invalid parameter" unless [:math, :reading, :writing].include?(subject)
    raise UnknownDataError,
      "Invalid parameter" unless [3,8].include?(grade)
    raise UnknownDataError,
      "Invalid parameter" unless [2008, 2009, 2010, 2011, 2012, 2013, 2014].
        include?(year)
    if grade == 3
      Clean.three_round(@third_grade[year][subject])
    else
      Clean.three_round(@eighth_grade[year][subject])
    end
  end

  def proficient_for_subject_by_race_in_year(subject, race, year)
    raise UnknownDataError,
      "Invalid parameter" unless [:math, :reading, :writing].include?(subject)
    raise UnknownDataError,
      "Invalid parameter" unless @races.include?(race)
    raise UnknownDataError,
      "Invalid parameter" unless [2008, 2009, 2010, 2011, 2012, 2013, 2014].
        include?(year)
    Clean.three_round(@race_ethnicity_data[race][year][subject])
  end

end
