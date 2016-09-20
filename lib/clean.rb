module Clean

  def self.three_truncate(percentage)
    percentage.to_s[0..4].to_f
  end

  def self.three_round(percentage)
    if percentage.class == Float
      percentage.round(3)
    else
      percentage
    end
  end

  def self.race_ethnicity(race_ethnicity)
    race_ethnicity = race_ethnicity.downcase
    if race_ethnicity == "hawaiian/pacific islander"
      race_ethnicity = race_ethnicity.gsub("hawaiian/", "")
      race_ethnicity = race_ethnicity.gsub(" ", "_").to_sym
    else
      race_ethnicity = race_ethnicity.gsub(" ", "_").to_sym
    end
    race_ethnicity
  end

  def self.percentage(percentage)
    if percentage == "N/A"
      percentage
    elsif percentage == "NA"
      percentage = "N/A"
    elsif percentage == "LNE"
      percentage = "N/A"
    else
      percentage = percentage.to_f
    end
  end

  def self.timeframe(timeframe)
    result = timeframe.split('-').map { |year| year.to_i }
  end
end
