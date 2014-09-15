#!/usr/bin/env ruby

$:.unshift File.expand_path("./lib/onlifehealth-coding-test")

require 'csv_reader'
require 'result_tracker'
require 'batting_average_tracker'
require 'slugging_percentage_tracker'
require 'triple_crown_tracker'

BATTING_CSV_FILENAME = File.expand_path("./Batting-07-12.csv")

result_tracker = ResultTracker.new(BattingAverageTracker, SluggingPercentageTracker, TripleCrownTracker)
CSVReader.read_into_tracker(BATTING_CSV_FILENAME, result_tracker)

puts result_tracker
