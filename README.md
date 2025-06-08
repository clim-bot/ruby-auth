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