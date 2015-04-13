require 'test_helper'
require 'flowmor_router'

# require 'action_dispatch/routing/inspector'
# Rails.application.routes_reloader.reload!
# puts "ROUTES: #{Rails.application.routes.routes.collect {|r| r.name }.inspect}"

module FlowmorRouter 
  class RouterClassesTest < ActiveSupport::TestCase
    
    class Foo 
      include ActiveModel::AttributeMethods
      define_attribute_methods :title, :slug, :name, :alt_name, :caption, :id
      attr_accessor :title, :slug, :name, :alt_name, :caption, :id
      
      @@routable = []

      class << self
        def after_save *args
        end
        alias :before_save :after_save
        alias :scope :after_save
      end

      def self.routable
        @@routable
      end

      def initialize(title, slug)
        @id = 1
        @title = title
        @caption = "#{title} (captioned)"
        @slug = slug
        @name = slug
        @alt_name = "alt-#{slug}"
        self.class.routable << self
      end
      
      include FlowmorRouter::ActsAsRoutable
    end
    
    test "defined correctly" do
      assert_kind_of Class, FlowmorRouter::RouterClasses
    end
  
    test "can register a class" do
      begin
        RouterClasses.register :obj, Object, {}
        assert RouterClasses.router_classes.map(&:model).include?(Object)
        assert RouterClasses.router_classes.map(&:actor).include?("obj")
      ensure
        RouterClasses.unregister Object
      end
    end
    
    test "Bar becomes routable" do
      begin
        class Bar < Foo
          acts_as_routable
        end
      
        item = Bar.new("FooBar", "foo-bar")
        rc = RouterClasses.router_classes.detect{|d| d.model == Bar}
        
        assert_equal Bar,                     rc.model
        assert_equal "bars",                  rc.actor
        assert_equal "bar#show",              rc.controller_action
        assert_equal "bars",                  rc.route_base_name
        assert_equal "/bars",                 rc.route_base_path
        assert_equal "foo-bar",               rc.name(item)
        assert_equal "flowmor_bars_routable", rc.scope_name
        assert_equal "/bars/foo-bar",         rc.route_path(item)
        assert_equal "path",                  rc.path_method_name
        assert_equal "url",                   rc.url_method_name
        assert_equal "bars_foo_bar",          rc.route_name(item)
      ensure
        RouterClasses.unregister Bar
      end
    end
    
    test "Baz becomes routable with named model" do
      begin
        class Baz < Foo
          acts_as_routable :foobaz, 
            prefix: [:foo, :bazs], 
            name_field: :alt_name,
            title_field: :caption
        end

        item = Baz.new("FooBaz", "foo-baz")
        rc = RouterClasses.router_classes.detect{|d| d.model == Baz}
        
        assert_equal Baz,                                 rc.model
        assert_equal "foobaz",                            rc.actor
        assert_equal "foobaz#show",                       rc.controller_action
        assert_equal [:foo, :bazs],                       rc.route_prefix(item)
        assert_equal "foobaz",                            rc.route_base_name
        assert_equal "/foobaz",                           rc.route_base_path
        assert_equal "alt-foo-baz",                       rc.name(item)
        assert_equal "flowmor_foobaz_routable",           rc.scope_name
        assert_equal "/foo/bazs/foobaz/alt-foo-baz",      rc.route_path(item)
        assert_equal "path",                              rc.path_method_name
        assert_equal "url",                               rc.url_method_name
        assert_equal "foo_bazs_foobaz_alt_foo_baz",       rc.route_name(item)
      ensure
        RouterClasses.unregister Baz
      end
    end
    
    test "Bat becomes routable with named model" do
      begin
        class Bat < Foo
          def batty
            "coo_coo-for-coco_puffs"
          end
          
          def custom_route
            "/foo/#{batty}"
          end
          
          def category 
            :crazy
          end
          
          acts_as_routable route: :custom_route, prefix: -> { :category }
        end
       
        item = Bat.new("FooBar", "foo-bar")
        rc = RouterClasses.router_classes.detect{|d| d.model == Bat}

        assert_equal Bat,                           rc.model
        assert_equal "flowmor_bats_routable",       rc.scope_name
        assert_equal "bats",                        rc.actor
        assert_equal "bat#show",                    rc.controller_action
        assert_equal "bats",                        rc.route_base_name
        assert_equal "/bats",                       rc.route_base_path
        assert_equal "foo-bar",                     rc.name(item)
        assert_equal "/foo/coo_coo-for-coco_puffs", rc.route_path(item)
        assert_equal "path",                        rc.path_method_name
        assert_equal "url",                         rc.url_method_name
        assert_equal "crazy_bats_foo_bar",          rc.route_name(item)
        assert_equal [:crazy],                      rc.route_prefix(item)
      ensure
        RouterClasses.unregister Bat
      end
    end

    test "Down becomes routable with named model" do
      begin
        class Down < Foo
          
          acts_as_routable delimiter: "_"
        end
       
        item = Down.new("A Serious Downer", nil)
        rc = RouterClasses.router_classes.detect{|d| d.model == Down}

        assert_equal Down,                      rc.model
        assert_equal "flowmor_downs_routable",  rc.scope_name
        assert_equal "downs",                   rc.actor
        assert_equal "down#show",               rc.controller_action
        assert_equal "downs",                   rc.route_base_name
        assert_equal "/downs",                  rc.route_base_path
        assert_equal "a_serious_downer",        rc.name(item)
        assert_equal "/downs/a_serious_downer", rc.route_path(item)
        assert_equal "path",                    rc.path_method_name
        assert_equal "url",                     rc.url_method_name
        assert_equal "downs_a_serious_downer",  rc.route_name(item)
        assert_equal nil,                       rc.route_prefix(item)
      ensure
        RouterClasses.unregister Down
      end
    end

    test "Fib becomes routable with named model" do
      begin
        class Fib < Foo
          
          def custom_name
            ["so_called", name.parameterize].join("-")
          end
          
          acts_as_routable name: :custom_name
          acts_as_routable :archive, controller_action: "fib#archive", name: :custom_name
        end
       
        item = Fib.new("FooBar", "foo-bar")
        rc = Fib.flowmor_fibs_router_class
        rca = Fib.flowmor_fibs_archive_router_class
        
        assert_equal Fib,                       rc.model
        assert_equal "fibs",                    rc.actor
        assert_equal "fib#show",                rc.controller_action
        assert_equal "fibs",                    rc.route_base_name
        assert_equal "/fibs",                   rc.route_base_path
        assert_equal "so_called-foo-bar",       rc.name(item)
        assert_equal "flowmor_fibs_routable",   rc.scope_name
        assert_equal "/fibs/so_called-foo-bar", rc.route_path(item)
        assert_equal "path",                    rc.path_method_name
        assert_equal "url",                     rc.url_method_name
        assert_equal "fibs_so_called_foo_bar",  rc.route_name(item)

        assert_equal Fib,                               rca.model
        assert_equal "archive",                         rca.actor
        assert_equal "fib#archive",                     rca.controller_action
        assert_equal "fibs_archive",                    rca.route_base_name
        assert_equal "/archive",                        rca.route_base_path
        assert_equal "so_called-foo-bar",               rca.name(item)
        assert_equal "flowmor_fibs_archive_routable",   rca.scope_name
        assert_equal "/archive/so_called-foo-bar",      rca.route_path(item)
        assert_equal "archive_path",                    rca.path_method_name
        assert_equal "archive_url",                     rca.url_method_name
        assert_equal "fibs_archive_so_called_foo_bar",  rca.route_name(item)
      ensure
        RouterClasses.unregister Fib
      end
    end
  end
end