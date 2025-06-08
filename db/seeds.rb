puts "Starting to seed the database..."

user = User.create!(
  email_address: "admin@example.com",
  password: "P@ssw0rd!",
  password_confirmation: "P@ssw0rd!"
)

puts "Seed successful! Created user: #{user.email_address} , #{user.password}"