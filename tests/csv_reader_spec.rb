require File.expand_path(File.join(File.dirname(__FILE__), "/requires"))

class ReadIntoTrackerMock
	def initialize(expected_rows)
		@expected_rows = expected_rows
		@row_number = 0
	end

	def on_csv_row(row)
		assert { expect(row).to match_array(@expected_rows[@row_number]) }

		@row_number += 1
	end

	def on_csv_end
	end
end

class OnCSVEndMock
	def initialize
		@csv_ended = false
	end

	def on_csv_row(row)
		assert { expect(@csv_ended).to eq(false) }
	end

	def on_csv_end
		assert { expect(@csv_ended).to eq(false) }

		@csv_ended = true
	end
end

describe CSVReader do
	context "::read_into_tracker" do
		expected_rows = [
				["1", "2", "3", "AA", "BB", "CC", "DD"],
				["4", "5", "6", "7", "EE", "FF"]
		]

		csv_filename = File.join(File.dirname(__FILE__), "/csv_reader_spec.csv")

		it "reads CSV rows into tracker" do
			CSVReader.read_into_tracker(csv_filename, ReadIntoTrackerMock.new(expected_rows))
		end

		it "calls tracker#on_csv_end after reading CSV rows into tracker" do
			CSVReader.read_into_tracker(csv_filename, OnCSVEndMock.new)
		end
	end
end
