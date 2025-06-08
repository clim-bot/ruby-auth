## Generate the Project
```shell
rails new ruby-auth --css tailwind --javascript importmap --use-propshaft
```

## Setting Up Authentication
```shell
bin/rails generate authentication
```

### Generating the Post Scaffold
```
bin/rails generate scaffold Post title:string body:text published:boolean user:references
```

## Setting Up Seed User
```shell
puts "Starting to seed the database..."

user = User.create!(
  email_address: "admin@example.com",
  password: "P@ssw0rd!",
  password_confirmation: "P@ssw0rd!"
)

puts "Seed successful! Created user: #{user.email_address} , #{user.password}"
```

## Generating DB and Migrating Tables
```shell
bin/rails db:create
bin/rails db:migrate
```

## Seeding the Database with the User
```shell
bin/rails db:seed
```

## Resetting the DB with migration and seed
```shell
bin/rails db:reset
```

## Running the app
```shell
bin/dev
```

## To view all available routes
```shell
http://localhost:3000/rails/info/routes
```

## Set Up Associations
To make user and post have association, please double check
your `user.rb` and `post.rb`.
```ruby
# app/models/user.rb
class User < ApplicationRecord
  has_many :posts, dependent: :destroy
  # other authentication code...
end

# app/models/post.rb
class Post < ApplicationRecord
  belongs_to :user
end
```

## Update your Route
```ruby
# config/routes.rb
Rails.application.routes.draw do
  resources :posts

  # Sessions (login/logout)
  resource :session, only: [ :new, :create, :destroy ], controller: "sessions"
  get    "/login",  to: "sessions#new",     as: :login
  post   "/login",  to: "sessions#create"
  delete "/logout", to: "sessions#destroy", as: :logout

  # Password reset
  resources :passwords, param: :token

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  root "posts#index"
end
```
## Returns the User association with the current session
We need to go to `app/controllers/concerns/authentication.rb` and create a method called `current_user`.
```ruby
module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session # Ensure session is resumed for authenticated users
    before_action :require_authentication # Require authentication for actions that need it
    helper_method :authenticated?, :current_user # Expose methods to views
  end

  # ...existing code...

  private
    # ...existing methods...

    # This method is called to ensure the user is logged in for actions that require it.
    def current_user
      Current.session&.user
    end
end
```

## Enforce Authentication Before Action
None authenticated users can only view the blogs we need to include a before action and a private method. We need to update the `post_controller.rb`.
```ruby
class PostsController < ApplicationController
  # This means users can view posts without logging in.
  skip_before_action :verify_authenticity_token, only: [ :index, :show ]
  # Allow unauthenticated access for index and show actions
  allow_unauthenticated_access only: [ :index, :show ]
  # This controller handles the CRUD operations for posts.
  before_action :authenticate_user!, except: [ :index, :show ]
  # Ensure the user is logged in for all actions except index and show
  before_action :set_post, only: [ :show, :edit, :update, :destroy ]
  # Ensure the post is set for actions that require it
  before_action :authorize_user!, only: [ :edit, :update, :destroy ]

  # rest of your controller...

  # POST /posts or /posts.json
  def create
    # Build a new post associated with the current user
    @post = current_user.posts.build(post_params)

    respond_to do |format|
      if @post.save
        format.html { redirect_to @post, notice: "Post was successfully created." }
        format.json { render :show, status: :created, location: @post }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @post.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_post
    @post = Post.find(params.expect(:id))
  end

  # Authenticate the user before allowing access to certain actions
  def authorize_user!
    redirect_to posts_path, alert: "Not authorized." unless @post.user == current_user
  end

  # Only allow a list of trusted parameters through.
  def post_params
      params.require(:post).permit(:title, :body, :published)
  end
end

```

## Removing the User ID from the New Post Form
Since we are already have the controller logic for it, the form doesn't need to handle user assignments.
Remove this line from `app/views/posts/_form.html.erb`.
```erb
<div class="my-5">
  <%= form.label :user_id %>
  <%= form.text_field :user_id, class: ["block shadow-sm rounded-md border px-3 py-2 mt-2 w-full", {"border-gray-400 focus:outline-blue-600": post.errors[:user_id].none?, "border-red-400 focus:outline-red-600": post.errors[:user_id].any?}] %>
</div>
```

## Optionals
### 404 Page
If the page does not exist, we can use ruby's built in 404 page. By updating the
`app/controllers/application_controller.rb`
```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  # Enable CSRF protection for all actions except those that allow unauthenticated access.
  rescue_from ActiveRecord::RecordNotFound, with: :not_found

  private
  # This method is called when a record is not found.
  def not_found
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end
end
```

### Logout button
If you want to add a logout button, you need to go to `app/views` and make a folder called `shared`
and then create a partial `_header.html.erb`
```erb
<nav class="w-full">
  <div class="flex justify-end items-center py-4 px-6">
    <% if current_user %>
      <%= button_to "Logout", logout_path, method: :delete, class: "bg-red-600 hover:bg-red-700 text-white font-semibold px-4 py-2 rounded" %>
    <% end %>
  </div>
</nav>
```
And after that go to `app/views/layouts/application.html.erb` and add this line of code inside the `<body>` tag, ussually right after `<body>`.
```erb
<%= render "shared/header" %>
```

### Hidding Show and Destroy Posts
We need to use the ERB conditional block to hide the `edit` and `destroy` post.
For example in the `app/views/posts/index.html.erb`:
```erb
<%# app/views/posts/index.html.erb %>
<% if current_user == post.user %>
  <%= link_to "Edit", edit_post_path(post), class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium" %>
  <%= button_to "Destroy", post, method: :delete, class: "w-full sm:w-auto rounded-md px-3.5 py-2.5 text-white bg-red-600 hover:bg-red-500 font-medium cursor-pointer", data: { turbo_confirm: "Are you sure?" } %>
<% end %>

<%# app/views/posts/show.html.erb
In the show action/view, Rails sets the instance variable @post.
post (without @) would only be defined in loops (like in index with @posts.each do |post| ... end).
Using @post is the “Rails way” in the show template. %>
<% if current_user == @post.user %>
  <%= link_to "Edit", edit_post_path(post), class: "w-full sm:w-auto text-center rounded-md px-3.5 py-2.5 bg-gray-100 hover:bg-gray-50 inline-block font-medium" %>
  <%= button_to "Destroy", post, method: :delete, class: "w-full sm:w-auto rounded-md px-3.5 py-2.5 text-white bg-red-600 hover:bg-red-500 font-medium cursor-pointer", data: { turbo_confirm: "Are you sure?" } %>
<% end %>
```
