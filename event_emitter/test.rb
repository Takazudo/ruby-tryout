require 'event_emitter'

class User
  include EventEmitter
  attr_accessor :name
end

user = User.new
user.name = 'Taro'
user.on :go do |data|
  puts "#{name} go to #{data[:place]}"
end

user.emit :go, { :place => 'mountain' }

module Hoge
  def self.moge
    on :foo do
      puts 'OMG!'
    end
  end
end

EventEmitter.apply Hoge

Hoge.moge

Hoge.on :foo do
  puts 'yeah!'
end

Hoge.emit :foo
Hoge.emit :foo
