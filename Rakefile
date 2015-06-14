begin
  require 'bundler/setup'
rescue LoadError
  puts 'You must `gem install bundler` and `bundle install` to run rake tasks'
end

require 'rdoc/task'
require 'engine_cart/rake_task'

RDoc::Task.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'Blacklight::Folders'
  rdoc.options << '--line-numbers'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

ZIP_URL = "https://github.com/projectblacklight/blacklight-jetty/archive/v4.6.0.zip"
require 'jettywrapper'

task :default => [:spec]


desc "Clean out the test rails app"
task :clean => ['engine_cart:clean', 'jetty:clean'] do
end


desc "Run test suite"
task :ci => ['clean', 'jetty:add_test_core', 'engine_cart:generate'] do
  jetty_params = Jettywrapper.load_config('test')
  error = Jettywrapper.wrap(jetty_params) do
    Rake::Task['spec'].invoke
  end
  raise "test failures: #{error}" if error
end

namespace :jetty do

  desc 'Add test-core to solr for test environment'
  task :add_test_core do
    require 'nokogiri'

    # copy config files
    FileUtils.mkdir_p('jetty/solr/test-core/conf')
    FileList['jetty/solr/blacklight-core/conf/*'].each do |f|
      cp_r("#{f}", 'jetty/solr/test-core/conf/', :verbose => true)
    end

    # add test-core to solr.xml
    file = File.read("jetty/solr/solr.xml")
    doc = Nokogiri::XML(file)
    blacklight = doc.at_css("core[name='blacklight-core']")
    test = blacklight.clone
    test['name'] = 'test'
    test['instanceDir'] = 'test-core'
    blacklight.add_next_sibling(test)
    File.open("jetty/solr/solr.xml", "w") do |f|
      f.write doc.to_xml
    end
  end
end
