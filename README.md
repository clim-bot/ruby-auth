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
bin/rails generate scaffold Post title:string body:text published:boolean
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

## Running the app
```shell
bin/dev
```