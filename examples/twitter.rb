require File.expand_path(File.join(File.dirname(__FILE__), 'helper'))

class Status
  include SMG::Resource

  root 'status'

  extract :id         , :class => :integer, :as => :status_id
  extract :created_at , :class => :datetime
  extract :text

end

class User
  include SMG::Resource

  root 'user'

  extract :id                 , :class => :integer, :as => :twitter_id
  extract :location           , :class => :string
  extract :status             , :class => Status
  extract :created_at         , :class => :datetime
  extract :name
  extract :screen_name

end

data = File.read(ROOT.join('spec/fixtures/twitter/pipopolam.xml'))
user = User.parse(data)

puts "#{user.screen_name} (#{user.name}), since #{user.created_at.strftime('%Y.%m.%d')}"
puts user.location
puts user.status.text

# EOF