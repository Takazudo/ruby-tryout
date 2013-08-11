require 'bundler'
Bundler.require

res = Uglifier.new.compile File.read 'hoge.js'

f = open 'hoge.min.js', 'w'
f.write res
f.close
