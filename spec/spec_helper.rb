require 'bundler/setup'
Bundler.require(:default, :test)

require 'gorillib/pathname'
Pathname.register_path(:wukong_root, File.expand_path('..', File.dirname(__FILE__)))
Pathname.register_path(:examples,    :wukong_root, 'examples')
Pathname.register_path(:tmp,         :wukong_root, 'tmp')

$LOAD_PATH.unshift(Pathname.path_to('lib'))
$LOAD_PATH.unshift(Pathname.path_to('spec', 'support'))

Dir[ Pathname.path_to('spec', 'support', '*.rb') ].each{|f| require f }

RSpec.configure do |config|
  include WukongTestHelpers
end
