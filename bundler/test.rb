require 'bundler'
Bundler.require

set :port, 2100
set :bind, '0.0.0.0'

get '/' do
  'hello world!'
end
