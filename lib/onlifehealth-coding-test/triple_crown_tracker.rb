class TripleCrownTracker
	def initialize(id, tracker)
		@tracker = tracker
		@leagues = {}
		@id = id
	end

	def add_player(player_id, league, batting_average, home_runs, rbi)
		if (!@leagues[league])
			@leagues[league] = [nil, 0, 0, 0]
		end

		if ((batting_average > @leagues[league][1]) && (home_runs > @leagues[league][2]) && (rbi > @leagues[league][3]))
			# New triple crown winner!
			@leagues[league] = [player_id, batting_average, home_runs, rbi]
			return
		end

		if (batting_average > @leagues[league][1])
			@leagues[league][0] = nil
			@leagues[league][1] = batting_average
		end

		if (home_runs > @leagues[league][2])
			@leagues[league][0] = nil
			@leagues[league][2] = home_runs
		end

		if (rbi > @leagues[league][3])
			@leagues[league][0] = nil
			@leagues[league][3] = rbi
		end
	end

	def end_of_players
		@leagues.each do |league, info|
			if (info[0] != nil)
				@tracker.on_triple_crown_winner(@id, info[0], league)
			end
		end
	end
end
