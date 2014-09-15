require File.expand_path(File.join(File.dirname(__FILE__), "/requires"))

class BattingAverageExpectedTrackerMock
	def initialize(expected_player_id, expected_improvement)
		@expected_player_id = expected_player_id
		@expected_improvement = expected_improvement
	end

	def on_batting_average_improvement(player_id, improvement)
		assert { expect(player_id).to eq(@expected_player_id) }
		assert { expect(improvement).to eq(@expected_improvement) }
	end
end

describe BattingAverageTracker do
	context "#set_year_one" do
		it "computes the batting average for year one and stores it in #average_year_one" do
			batting_average = BattingAverageTracker.new("testplayer1", nil)
			batting_average.set_year_one(5, 25)

			# Expect syntax doesn't work here for some reason
			assert { batting_average.average_year_one == 0.2 }
		end
	end

	context "#set_year_two" do
		it "computes the batting average for year two and stores it in #average_year_two" do
			batting_average = BattingAverageTracker.new("testplayer2", nil)
			batting_average.set_year_two(10, 100)

			# Expect syntax doesn't work here for some reason
			assert { batting_average.average_year_two == 0.1 }
		end
	end

	context "#set_year_one and #set_year_two" do
		it "computes the batting average for year one and year two and calls tracker#on_batting_average_improvement" do
			batting_average = BattingAverageTracker.new("testplayer3", BattingAverageExpectedTrackerMock.new("testplayer3", -0.1))
			batting_average.set_year_one(5, 25)
			batting_average.set_year_two(10, 100)
		end
	end
end
