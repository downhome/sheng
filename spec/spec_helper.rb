require 'simplecov'
SimpleCov.start

require 'sheng'
require 'equivalent-xml'
require 'equivalent-xml/rspec_matchers'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus
  config.order = 'random'
  config.include PathHelper
  config.include XMLHelper
end
