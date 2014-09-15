class SluggingPercentageTracker
	attr_accessor :player_id
	attr_accessor :percentage

	def initialize(player_id, tracker)
		@percentage = 0

		@player_id = player_id
		@tracker = tracker
	end

	def set_year_one(hits, doubles, triples, home_runs, at_bats)
		if (at_bats != 0)
			@percentage = ((hits - doubles - triples - home_runs) + (2 * doubles) + (3 * triples) + (4 * home_runs)) / at_bats.to_f
		else
			@percentage = 0
		end

		@tracker.on_slugging_percentage(player_id, @percentage)
	end
end
