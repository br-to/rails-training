User.find_or_create_by(email: 'test@example.com') do |user|
  user.name = 'Test User'
end
