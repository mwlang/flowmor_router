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
    instance_exec &say_it
  end
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

class Bar
  def self.register(name = nil, options = {})
    if name.nil?
      name = "foobaz"
    elsif name.is_a?(Hash) && options == {}
      name, options = "foobar", name
    end
    puts [name, options].inspect
  end
end

Bar.register :something, :foo => 1, :bar => 2
Bar.register \
  foo: 2, 
  bar: -> { puts "yeah" }, 
  baz: 3
Bar.register