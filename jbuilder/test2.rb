require 'bundler'
Bundler.require

class Person

  def initialize name, age
    @name = name
    @age = age
  end

  def to_builder
    Jbuilder.new do |person|
      person.name @name
      person.age @age
    end
  end

end

class Company

  def initialize name, president
    @name = name
    @president = president
  end

  def to_builder
    Jbuilder.new do |company|
      company.name @name
      company.president @president.to_builder
    end
  end

end

company = Company.new('Doodle Corp', Person.new('John Stobs', 58))
puts company.to_builder.target! # convert nested
