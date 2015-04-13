class Foo
  def hello
    puts "gonna say hello"
    "Hello #{world}"
  end
  
  def world
    "World"
  end
  
  attr_reader :say_it
  
  def initialize options = {}
    @say_it = options[:another_way] || method(:hello)
    define_singleton_method(:world, options[:another_world]) if options[:another_world]
  end
  
  def speak
    hello
  end
end

class Proxy
  def
end

begin
  foobar = Foo.new
  puts "lazy?"
  puts foobar.speak
rescue Exception => e
  puts "#{e.class.to_s}: #{e.message}"
end

begin
  foobaz = Foo.new(another_way: lambda { "#{hello}, Sir!" })
  puts "lazy?"
  puts foobaz.speak
rescue Exception => e
  puts "#{e.class.to_s}: #{e.message}"
end

begin
  foobaz = Foo.new(another_world: lambda { "Earth" })
  puts "lazy?"
  puts foobaz.speak
rescue Exception => e
  puts "#{e.class.to_s}: #{e.message}"
end

