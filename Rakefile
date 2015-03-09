require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:rbtest) do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_rbed.rb']
end

Rake::TestTask.new(:ctest) do |t|
  t.libs << "test"
  t.test_files = FileList['test/test_crbed.rb']
end

task :test => [:rbtest, :ctest]

task :default => :test

require "rake/extensiontask"

task :build => :compile

Rake::ExtensionTask.new("rbed") do |ext|
  ext.name = 'bed'
  ext.lib_dir = "lib/rbed"
end
