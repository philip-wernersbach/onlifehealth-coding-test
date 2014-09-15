$:.unshift File.expand_path(File.join(File.dirname(__FILE__), "../lib/onlifehealth-coding-test"))

require 'wrong/adapters/rspec'
require 'wrong'

require 'rspec/expectations'

require 'csv_reader'
require 'result_tracker'
require 'batting_average_tracker'
require 'slugging_percentage_tracker'
require 'triple_crown_tracker'

include Wrong
include RSpec::Matchers
