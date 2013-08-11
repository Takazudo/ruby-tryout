require 'bundler'
Bundler.require

class Foo

  def initialize name, age
    @name = name
    @age = age
  end

  def name
    @name
  end

  def age
    @age
  end

end
