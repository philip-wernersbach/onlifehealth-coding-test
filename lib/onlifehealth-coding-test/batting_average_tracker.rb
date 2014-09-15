class BattingAverageTracker
	attr_accessor :player_id
	attr_accessor :average_year_one
	attr_accessor :average_year_two
	attr_accessor :improvement

	def initialize(player_id, tracker)
		@average_year_one = 0
		@average_year_two = 0
		@improvement = 0
		@year_one = nil
		@year_two = nil

		@player_id = player_id
		@tracker = tracker
	end

	def set_year_one(hits, at_bats)
		@year_one = [hits, at_bats]
		compute_average

		if (@year_two != nil)
			@tracker.on_batting_average_improvement(player_id, @improvement)
		end
	end

	def set_year_two(hits, at_bats)
		@year_two = [hits, at_bats]

		compute_average
		if (@year_one != nil)
			@tracker.on_batting_average_improvement(player_id, @improvement)
		end
	end

	def compute_average
		if (@year_one != nil)
			@average_year_one = @year_one[0] / @year_one[1].to_f
		else
			@average_year_one = 0
		end

		if (@year_two != nil)
			@average_year_two = @year_two[0] / @year_two[1].to_f
		else
			@average_year_two = 0
		end

		@improvement = @average_year_two - @average_year_one
	end
end
