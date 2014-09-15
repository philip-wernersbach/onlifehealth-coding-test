#!/bin/sh

bundle install
bundle exec rspec ./tests
bundle exec ruby ./bin/onlifehealth-coding-test.rb
