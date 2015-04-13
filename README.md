# FlowmorRouter

FlowmorRouter is a Rails::Engine that enables ActiveRecord Models to route themselves in Rails 4.x applications. For example:

```ruby
class Post < ActiveRecord::Base
  acts_as_routable
end

p = Post.create(title: "My First Post")
puts p.path # => "/posts/my-first-example"
```

or in a view where PostCategory has_many :posts

```haml
- PostCategory.all.each do |category|
  %h3= link_to category.title, category.path
  %ul
    - category.posts.recently_published.each do |post|
      %li= link_to post.title, post.path
```

FlowmorRouter also supports static pages.  All you have to do is create an app/views/static folder and place templates in that folder.  Routes are automatically generated and served by the StaticController.  Currently, this only goes one level deep.  That is, sub-directories of static not yet implemented.  Useful for rapidly importing WordPress archive pages!  For an idea of how I rapidly ported my WordPress and python/Zope websites to Rails, check out the following [gist](https://gist.github.com/mwlang/a4dbf5c098fd8f9502b2).

If you're blogging with markdown or other file-based approaches, you'll appreciate how easy it is to reference your posts in those static views with linking:

```haml
=%h1 About
%p Please be sure to read my post, #{link_to "How to Use Flowmor Router", post_how_to_use_flowmor_router_path}
```

Every model instance's path is named after the model and title/slug/name for the record.  How the paths and path names are generated can be customized.


## State of the project

* 0.2.1
* Tested and Works on Rails 4.x and Ruby 2.x
* Changed usage pattern to use act_as_routable instead of inheriting from RoutableRecord
* Completely refactored to remove as much code out of the ActiveRecord class and into a new RouterClasses object.
* Also greatly simplified some of the implementation and cleaned up weird naming conventions.
* Added ability to have multiple actors on one model
* Added suffix and prefix

Its got enough functionality to work really well for me [(mwlang)](https://github.com/mwlang) in its current form.  It's a simple implementation with relatively few lines of code, adequately test covered.  It works and is used in production on a handful of sites.  You can see it in action on [my personal site](http://codeconnoisseur.org) and [business site](http://cybrains.net).

### Is it For You?

This isn't for everyone.  The Flowmor Router build routes ahead of time based on objects in the database.  Rails purists will argue this method pollutes the routes space.  It does provide functionality similar to [friendly_id](https://github.com/norman/friendly_id) or by simply redefining the id of a model with AR's #to_param.  If you run multiple instances of an application, you'll need to take care of syncing when the database is updated.  The simplest way to do this is by adding Post.reload_routes (for example) to the before_filter callback of the controller.  Sounds like a performance killer, but its really not.  Just think every time you refresh during development that the routes are reloaded! 

On the other hand, this approach allows you a lot of flexibility to creating truly custom routes in your app.  It also allows you to avoid using a global "match any" in your config/routes.rb.  A use case is porting over a WordPress site to Rails where there was a highly customized permalink structure in place.  It's really only meant for "#show" actions.  I personally wouldn't try to also incorporate CRUD actions with friendly route names.  Rails' conventional routes does the job extremely well for CRUD actions.  This also means other gems like ActiveAdmin will work as advertised since friendly routes aren't interfering with Rails routes.

## TL;DR

For those of you who just need good examples and not a lot of words.  The following examples are class definitions followed by what's generated:

```ruby
class KitchenSink < ActiveRecord::Base
  acts_as_routable :sink,
    scope: -> { where(nothing_missing: true) }
    prefix: -> { :kitchen },
    suffix: [:faucet, :drain],
    delimiter: "_",
    name_field: :appliance
    title_field: :display
    name: -> { :sluggerize }
    route: -> { :route }

    def kitchen
      [:fancy, :kitchen]
    end
      
    def sluggerize 
      self.title.downcase.parameterize("_")
    end
    
  def route 
    "/kitchen/sink/#{sluggerize}"
  end
end
```
NOTE: prefix and suffix can be either a Symbol/String, an Array of such, or a Proc which references a method on the Model that returns a String/Symbol or Array of such.

```ruby  
class Post < ActiveRecord::Base
  acts_as_routable
end

@post = Post.create(title: "Title me Silly")

route_name   = posts_title_me_silly
route_path   = posts_title_me_silly_path
route_url    = posts_title_me_silly_url
@post.path   = /posts/title-me-silly
@post.url    = http://example.com/posts/title-me-silly
```

```ruby  
class Post < ActiveRecord::Base
  acts_as_routable :ramblings
end

@post = Post.create(title: "Title me Silly")

route_name   = ramblings_title_me_silly
route_path   = ramblings_title_me_silly_path
route_url    = ramblings_title_me_silly_url
@post.path   = /ramblings/title-me-silly
@post.url    = http://example.com/ramblings/title-me-silly
```

```ruby
class Post < ActiveRecord::Base
  acts_as_routable :ramblings, prefix: :posts
end

@post = Post.create(title: "Title me Silly")

route_name   = posts_ramblings_title_me_silly
route_path   = posts_ramblings_title_me_silly_path
route_url    = posts_ramblings_title_me_silly_url
@post.path   = /posts/ramblings/title-me-silly
@post.url    = http://example.com/posts/ramblings/title-me-silly
```

```ruby
class Post < ActiveRecord::Base
  acts_as_routable :ramblings, prefix: [:blog, :posts]
end

@post = Post.create(title: "Title me Silly")

route_name   = blog_posts_ramblings_title_me_silly
route_path   = blog_posts_ramblings_title_me_silly_path
route_url    = blog_posts_ramblings_title_me_silly_url
@post.path   = /blog/posts/ramblings/title-me-silly
@post.url    = http://example.com/blog/posts/ramblings/title-me-silly
```

```ruby
class Post < ActiveRecord::Base
  belongs_to :category
  acts_as_routable :ramblings, prefix: -> { category.name }
  acts_as_routable :archive, suffix: [:posts]
end

@post = Post.create(title: "Title me Silly")

route_name   = silly_category_ramblings_title_me_silly
route_path   = silly_category_ramblings_title_me_silly_path
route_url    = silly_category_ramblings_title_me_silly_url
@post.path   = /silly-category/posts/ramblings/title-me-silly
@post.url    = http://example.com/silly-category/posts/ramblings/title-me-silly

# AND

route_name               = archive_posts_title_me_silly
route_path               = archive_posts_title_me_silly_path
route_url                = archive_posts_title_me_silly_url
@post.posts_archive_path = /archive/posts/title-me-silly
@post.posts_archive_url  = http://example.com/archive/posts/title-me-silly
```

```ruby
class Post < ActiveRecord::Base
  acts_as_routable, scope: -> { where(published: true) }
  acts_as_routable :archive, prefix: [:posts]
end

@post = Post.create(title: "Title me Silly")

route_name   = posts_title_me_silly
route_path   = posts_title_me_silly_path
route_url    = posts_title_me_silly_url
@post.path   = /posts/title-me-silly
@post.url    = http://example.com/posts/title-me-silly

# AND

route_name               = posts_archive_title_me_silly
route_path               = posts_archive_title_me_silly_path
route_url                = posts_archive_title_me_silly_url
@post.posts_archive_path = /posts/archive/title-me-silly
@post.posts_archive_url  = http://example.com/posts/archive/title-me-silly
```  

### To Install

Add to your Rails project Gemfile:

```
gem 'flowmor_router'
```

And then run the `bundle install` command.

## Convention over Configuration

I wanted a *simple* implementation and library to work with, so the convention is the model has a `title` field and a `name` field.  You (or your user) sets the title and the name field, which should be populated with a parameterized/routable value.  Just for kicks, if you don't have a name field on the model, then the Title field is always used to generate a parameterized value.  Hyphens are used by default instead of underscores because Google Webmaster Guidelines favors hyphens over underscores for SEO.  But you can override this passing the :delimiter option.

For example, "FlowmorRouter, the amazing little engine that could" will populate the name field with 'flowmor-router-the-amazing-little-engine-that-could'.  The controller by convention will have the same name as the model's name while the default action will be the #show action on that controller.  If you have a Post model, then its expected that your application has a PostController.  You're expected to provide the controller implementation.  Here's an example:

```ruby
class PostController < ApplicationController
  before_action :set_post, only: [:show]

  private
  
  def set_post
    @post = Post.find(params[:id])
  end
end
```

Note that you can find the record using the params[:id] which will be the actual id of the record because the routes are constructed specific to the ID for the object to be fetched.  This way we can skip the whole #to_param and params[:id].to_i non-sense or doing a more expensive SQL query and indexing on real titles, names, etc.  The other thing I like about this approach is that it plays nice with other toys like ActiveAdmin, which can get finicky about those #to_param changes.

To make an ActiveRecord model routable, call acts_as_routable after generating the model like so:

```ruby
class Post < ActiveRecord::Base
  acts_as_routable
  # ...
end
```

### By Convention...

The router looks for a :name field as the valid end of the route string ("my-fancy-post-title").  You're responsible for populating this field with a valid and sensible value for URI strings.  

If the :name field is missing, the router will compute a parameterized name from the :title field.  That is, if the :title field contains "My Fancy Pants Post" then the computed name (a.k.a. slug, or parameterized value) will be "my-fancy-pants-post".  This is appended to arrive at the fully qualified route.

The model that you add "acts_as_routable" to becomes the root of the route.  So Post ```ActiveRecord::Base; acts_as_routable; end``` will yield routes starting at "/posts/" and ultimately "/posts/my-fancy-pants-posts" in the above example's case.

### Conventions Suck, I Really Want to Customize!

Ok, here's how to do it.  


#### :title_field, :name_field  and :name

To change the field that the route name is derived from:

```ruby
class NewsArticle < ActiveRecord::Base
  acts_as_routable \
    title_field: :caption,   # changes from :title to :caption
    name_field: :slug        # changes from :name to :slug
end
```

Alternatively, you can do a lazy evaluation that incorporates other data for the record by passing the :name property

```ruby
class NewsArticle < ActiveRecord::Base
  acts_as_routable name: :custom_slug
  
  def custom_slug
    "#{self.author.name}_#{self.name}".parameterize("_")
  end
end
```

Using the :name property supersedes both :name_field and :title_field properties

To change the controller and action:

```ruby
class PostCategory < ActiveRecord::Base
  acts_as_routable controller_action: "blog#category"
end
```

To change how the route and route name are constructed (say you have Post that belongs_to PostCategory and need to avoid naming collision should two posts have same title, but belong to different categories):

```ruby
class Post < ActiveRecord::Base
  belongs_to :category

  acts_as_routable prefix: -> { :category },
    controller_action: "blog#show"

  # defaults to "general" category when none assigned
  def category
    (self.category.try(:name) || "general").parameterize
  end
end

@post.create('Programming Ruby', category: Category.find_by_name("General"))
@post.path # => /general/posts/programming-ruby
```

Note that the Proc triggers calling the model's "category" method when it's time to construct the route name and path.

Similar to :prefix is the :suffix and it's inserted into the route constructed right before the record's name value.

### route

If you want to skip all the fancy route building provided by the Engine, then pass in a Proc to the :route option.

```ruby
class Post < ActiveRecord::Base
  acts_as_routable route: :custom_route
  
  def custom_route
    "/posts/#{date_created.strftime("%Y/%m/%d/")}#{name.parameterize}"
  end
end
```

### delimiter 

The :delimiter option allows you to change the default hyphen to something else when the route name is computed from the title field.

```
class Post < ActiveRecord::Base
  acts_as_routable delimiter: "_-_"
end

@post.path # => /posts/my_-_silly_-_title
```

If you need to get any fancier than that, then just about everything you need can be found in the [lib/flowmor_router/acts_as_flowmor_routable.rb](https://github.com/mwlang/flowmor_router/blob/master/lib/flowmor_router/acts_as_flowmor_routable.rb) implementation.

By default, all acts_as_routable models and their instances are added to the routes table.  What gets routed can be customized by supplying a :scope option.

```ruby
class Article < ActiveRecord::Base
  acts_as_routable scope: -> { where published: true }
  # ...
end
```
### TODO and Contributing

This is largely an extraction of functionality from multiple Rails projects.  As such, it has the features I needed to fully extract to the engine.  However, some possible enhancements came to mind as I pulled this together:

* if a model belongs_to another model, then use ActiveRecord's Reflections to automatically build richer routes
* scan sub-directories under static to build nested pages that the static_controller can serve.
* potentially optimize the route generator to only update the routes that actually changed (currently all routes are triggered to reload).

Please don't hold your breath for me, though.  Unless [I need 'em for a specific project](http://en.wikipedia.org/wiki/You_aren%27t_gonna_need_it), they won't happen.  If you need it, implement and contribute back with pull request.  I'll take enhancements as long as they're test covered and don't break backwards compatibility.

## Testing

Testing makes use of a dummy Rails app, which can be found under [test/dummy folder](https://github.com/mwlang/flowmor_router/tree/master/test/dummy).  The test scripts for this app is under [test/dummy/test](https://github.com/mwlang/flowmor_router/tree/master/test/dummy/test) and you'll find many of the examples presented above as working examples in this dummy app.

To test for the first time, you'll need to initialize the database with:

```
RAILS_ENV=test rake db:migrate
```

Following this, you can run the test suite with:

```
rake test
```

### LICENSE

This project uses MIT-LICENSE.  Please see the MIT-LICENSE file.