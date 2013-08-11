require 'bundler'
Bundler.require
require './test1.rb'

describe Foo do
  
  it 'should have name' do
    name = 'someone'
    foo = Foo.new name, 10
    (expect foo.name).to be name
  end

  it 'should have age' do
    foo = Foo.new 'someone', 10
    (expect foo.age).to be 10
  end
  
end
