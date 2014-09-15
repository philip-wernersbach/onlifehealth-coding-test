# result_tracker.rb
# Copyright (c) 2014 Philip Wernersbach
# Part of onlifehealth-coding-test
#
# ResultTracker gets called by CSVReader for each row in the Batting CSV file.
# ResultTracker then leverages several other trackers for statistical information.
# If the other trackers have useful results, they call callbacks in ResultTracker,
# and ResultTracker stores the results.

class ResultTracker
	# Some configurable constants
	BATTING_AVERAGE_YEAR_ONE = 2009
	BATTING_AVERAGE_YEAR_TWO = 2010
	SLUGGING_PERCENTAGE_YEAR_ONE = 2007
	TRIPLE_CROWN_YEAR_ONE = 2011
	TRIPLE_CROWN_YEAR_TWO = 2012
	OAKLAND_A_TEAM_ID = "OAK"
	AL_LEAGUE_ID = "AL"
	NL_LEAGUE_ID = "NL"

	def initialize(batting_average_tracker, slugging_percentage_tracker, triple_crown_tracker)
		# Initialize our variables
		@fields = []
		@slugging_percentages = []
		@most_improved_batting_average = [nil, 0]
		@players = {}
		@triple_crown_winners = {
			TRIPLE_CROWN_YEAR_ONE => {
				AL_LEAGUE_ID => nil, NL_LEAGUE_ID => nil
			},
			TRIPLE_CROWN_YEAR_TWO => {
				AL_LEAGUE_ID => nil, NL_LEAGUE_ID => nil
			}
		}

		@line_one_read = false
		@triple_crown_winner_year_one = nil
		@triple_crown_winner_year_two = nil

		# Store the classes for the batting average tracker and the slugging percentage tracker so
		# we can instantiate trackers later.
		@batting_average_tracker = batting_average_tracker
		@slugging_percentage_tracker = slugging_percentage_tracker

		# We only need two instances of the triple crown tracker, one for each year we want to track.
		@triple_crown_year_one = triple_crown_tracker.new(TRIPLE_CROWN_YEAR_ONE, self)
		@triple_crown_year_two = triple_crown_tracker.new(TRIPLE_CROWN_YEAR_TWO, self)
	end

	# This gets called when there is a new CSV row from the Batting file.
	def on_csv_row(row)
		# Declare our variables ahead of time.
		# This is purely a stylistic choice, we could declare them when we use them too
		player = {}
		batting_average = nil

		# Check if its the first line. The first line contains the field names.
		# We dynamically map fields to columns, which allows the CSV to be in any order
		if (@line_one_read == false)
			# Its the first line, map fields to columns
			row.each_with_index { |field, i| @fields[i] = field }
			@line_one_read = true
		else
			# Its not the first line, so this line contains player data.
			# Map the player data into a hash.
			row.each_with_index do |value, i|
				case @fields[i]
				when "playerID"
					player[:player_id] = value
				when "yearID"
					player[:year_id] = value.to_i
				when "league"
					player[:league] = value
				when "teamID"
					player[:team_id] = value
				when "AB"
					player[:at_bats] = value.to_i
				when "H"
					player[:hits] = value.to_i
				when "2B"
					player[:doubles] = value.to_i
				when "3B"
					player[:triples] = value.to_i
				when "HR"
					player[:home_runs] = value.to_i
				when "RBI"
					player[:rbi] = value.to_f
				end
			end

			# Make sure there is a slot for this player in our player storage.
			if (!@players[player[:player_id]])
				@players[player[:player_id]] = {}
			end

			# Make sure there is a batting average tracker for this player.
			if (!@players[player[:player_id]][:batting_average_tracker])
				@players[player[:player_id]][:batting_average_tracker] = @batting_average_tracker.new(player[:player_id], self)
			end

			if (player[:at_bats] >= 200)
				# If the player has more than 200 at-bats, record the batting average for the years we care about.

				case player[:year_id]
				when BATTING_AVERAGE_YEAR_ONE
					@players[player[:player_id]][:batting_average_tracker].set_year_one(player[:hits], player[:at_bats])
				when BATTING_AVERAGE_YEAR_TWO
					@players[player[:player_id]][:batting_average_tracker].set_year_two(player[:hits], player[:at_bats])
				end
			end

			# Record the slugging percentages for the Oakland A's only, and only for the year we care about.
			if ((player[:team_id] == OAKLAND_A_TEAM_ID) && (player[:year_id] == SLUGGING_PERCENTAGE_YEAR_ONE))

				# Make sure there is a slugging percentage tracker for this player.
				if (!@players[player[:player_id]][:slugging_percentage_tracker])
					@players[player[:player_id]][:slugging_percentage_tracker] = @slugging_percentage_tracker.new(player[:player_id], self)
				end

				# Record the team id.
				@players[player[:player_id]][:team_id] = player[:team_id]

				# Record the slugging percentage.
				@players[player[:player_id]][:slugging_percentage_tracker].set_year_one(player[:hits], player[:doubles], player[:triples],
					player[:home_runs], player[:at_bats])
			end

			# If the player has at least 400 at-bats, they're triple crown eligible
			if (player[:at_bats] >= 400)
				# Only compute triple crowns for the years we care about.
				case player[:year_id]
				when TRIPLE_CROWN_YEAR_ONE
					# Instantiate a new batting average tracker so that we can compute the player's batting average on-demand.
					batting_average = @batting_average_tracker.new(player[:player_id], nil)
					batting_average.set_year_one(player[:hits], player[:at_bats])

					# Add a player for the possible triple crown.
					@triple_crown_year_one.add_player(player[:player_id], player[:league], batting_average.average_year_one, player[:home_runs], player[:rbi])
				when TRIPLE_CROWN_YEAR_TWO
					# Instantiate a new batting average tracker so that we can compute the player's batting average on-demand.
					batting_average = @batting_average_tracker.new(player[:player_id], nil)
					batting_average.set_year_one(player[:hits], player[:at_bats])

					# Add a player for the possible triple crown.
					@triple_crown_year_two.add_player(player[:player_id], player[:league], batting_average.average_year_one, player[:home_runs], player[:rbi])
				end
			end
		end
	end

	# This gets called when there are no more rows in the CSV file.
	def on_csv_end
		# Let our triple crown trackers know that we don't have any more players to process.
		# This allows us to get any possible triple crown results.
		@triple_crown_year_one.end_of_players
		@triple_crown_year_two.end_of_players
	end

	# Called whenever a batting average improvement is computed.
	def on_batting_average_improvement(player_id, improvement)
		# We don't need the batting average tracker anymore, allow it to garbage collect
		@players[player_id][:batting_average_tracker] = nil

		# Record the player with the most improved batting average.
		if (improvement > @most_improved_batting_average[1])
			@most_improved_batting_average[0] = player_id
			@most_improved_batting_average[1] = improvement
		end
	end

	# Called whenever a slugging percentage is computed.
	def on_slugging_percentage(player_id, percentage)
		# We don't need the slugging percentage tracker anymore, allow it to garbage collect
		@players[player_id][:slugging_percentage_tracker] = nil

		# We only care about the slugging percentages for the Oakland A's.
		if (@players[player_id][:team_id] == OAKLAND_A_TEAM_ID)
			# Record the slugging percentage.
			@slugging_percentages << [player_id, percentage]
		end
	end

	# Called whenever there is a triple crown winner.
	# Here, id is the year_id.
	def on_triple_crown_winner(id, player_id, league)
		@triple_crown_winners[id][league] = player_id
	end

	# Implement to_s so that the string representation of this object is useful.
	def to_s
		retval = "Most Improved Batting Average From #{BATTING_AVERAGE_YEAR_ONE} to #{BATTING_AVERAGE_YEAR_TWO}:\n" +
			"\t-> Player: #{@most_improved_batting_average[0]}\n" +
			"\t-> Improvement: #{@most_improved_batting_average[1]}\n" +
			"Slugging Percentages From #{SLUGGING_PERCENTAGE_YEAR_ONE} For Selected Players:\n"

		@slugging_percentages.each do |info|
			retval += "\t-> Player: #{info[0]}\n" +
				"\t\t-> Slugging Percentage: #{info[1]}\n"
		end

		@triple_crown_winners.each do |year, info|
			info.each do |league, player_id|
				if (player_id == nil)
					player_id = "(No Winner)"
				end

				retval += "Triple Crown Winner:\n" +
					"\t-> Year: #{year}\n" +
					"\t-> League: #{league}\n" +
					"\t-> Player: #{player_id}\n"
			end
		end

		return retval
	end
end
