require 'csv'

module DataExtractor

  def self.extract(file_data, type)
    data = file_data[type]
    contents = {}
    data.each do |key,value|
      contents[key] = CSV.read value, headers: true, header_converters: :symbol
    end
    contents
  end

end
