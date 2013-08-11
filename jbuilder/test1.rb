require 'bundler'
Bundler.require

res = Jbuilder.encode do |json|
  json.content 'foooo'
  json.props do
    json.prop1 = 'prop1val'
    json.prop2 = 'prop2val'
    json.prop3 = 'prop3val'
  end
  numbers = [1,2,3,4]
  json.numbers numbers do |number|
    json.num number
  end
  json.numbersArray [1,2,3,4]
end

puts res

