require 'csv'

class CSVReader
	def self.read_into_tracker(filename, tracker)
		CSV.foreach(filename) do |row|
			tracker.on_csv_row(row)
		end

		tracker.on_csv_end
	end
end
