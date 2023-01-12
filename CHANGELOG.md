# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Released]

### Added

- short description to Category
- Show benchmark boundaries on gauge graph
- Add bullet gem to optimize sql queries
- Add rubocop for formatting
- Upgrade to rails 7
- Add parallel test gem for to run tests faster
- Add simplecov gem to see test coverage
- Show survey response rate for students and teachers
- Cap teacher response rate at 100
- Show admin data collection rate
- Bump ruby version to 3.1.0
- Add previous year data.
- Add scale to framework. Calculations for scores bubble up through the framework.
- Change the threshold for sufficiency from a static number of responses to a response rate; from a minimum threshold of 17 teacher responses per survey item in a measure to 25 percent response rate in a subcategory and a minimum of 196 student responses per survey item in a measure to 25 percent response rate in a subcategory.
- Correct response rate for short-form schools.
- Correct scores for short-form schools
- Show historical data even if a response rate cannot be calculated for a year of information.
- Cap student response rate at 100
- Add metadata for 2019-20 school year.
- Add historical data
- Add student and teacher metadata
- Change wording of leadership scale
  bundle exec rake db:seed
- Delete s-grmi scale
- Add deployment script for beta. Runs tests before deployment to Heroku's git server
- Add new set of student results for 2016-17
- Exclude results from boston. Add foreign key from school to district
- Add admin data from 2016-17 and 2017-18

- Add Analyze page
- From analyze page, selecting a different school from the dropdown. Changed behavior so user remains on analyze page
- Updated 2016-17 student survey responses
- Add one off script to reset admin data values
- Add school: Attleboro Community Academy
- Add survey item responses for attleboro
- Create category and subcategory selectors on analyze page that allow a user to select which subcategory to view
- Create year selection checkboxes on analyze page that allow user to select the academic years of data to view
- Allow user to deselect all academic years
- Add tooltip next to year checkboxes to inform the user that year contains no data. Also disable checkbox
- Analyze bars have a minimum height
- Add survey results for Winchester 2021-22
- Speed up score calculations
- Reduce number of sql queries
- Precalculate response rates
- Add page caching
- Add counter caches
- Detect the latest year for which a school has data and direct a user to that year when routing from welcome page
- Modify behavior of insufficient data indicators for admin data items. Now we show indicators in line with the admin data item descriptions to indicate which items are missing data
- Add student demographic data to the database
  + `bundle exec rake data:load_students`
- Add students by group graph on analyze page
- Precalculate race scores for analyze page
  + `bundle exec rake one_off:reset_race_scores` : limit which years/schools/measures/races are processed
  + `bundle exec rake data:reset_race_scores`  : reset all race scores
- Add 'all data' radio button to analyze page
- Read survey results from sftp
- add admin data for 3A-i and 3B-i
- Fix bug where cultural responsiveness gives a false score of 1 when there is actually no data for that year

## [Unreleased]

### Added

