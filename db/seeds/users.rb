puts "Creating test user ..."

User.find_or_create_by(email: Faker::Internet.email) do |user|
  user.password = 'SecurePassword@1234'
end

puts "User with email #{User.last.email} created."
