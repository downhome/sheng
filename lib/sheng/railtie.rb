require 'rails'

module Sheng
  class MyRailtie < Rails::Railtie
    #
    # Adds ability to run gem's rake rasks from Rails enviriptment.
    #
    rake_tasks do
      Dir[File.join(File.dirname(__FILE__),'tasks/*.rake')].each do |f|
        load f
      end
    end
  end
end
