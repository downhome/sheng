#
# Run all specs
#
namespace :sheng do
  task :test do
    sh "bundle exec rspec #{File.expand_path '../../../', __FILE__}"
  end
end
