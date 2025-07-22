desc "Fill the database tables with some sample data"
task({ :sample_data => :environment }) do
  puts "Sample data task running"
  User.destroy_all
  Board.destroy_all
  Post.destroy_all
  
  ActiveRecord::Base.connection.tables.each do |t|
    begin
      ActiveRecord::Base.connection.execute("ALTER SEQUENCE #{t}_id_seq RESTART WITH 1")
    rescue ActiveRecord::StatementInvalid
      # Skip tables that don't have an id sequence
    end
  end
  
  usernames = ["alice","bob", "carol", "dave", "eve"]

  User.delete_all
ActiveRecord::Base.connection.reset_pk_sequence!('users')

  usernames.each do | username |

      user = User.new
      user.email = "#{username}@example.com"
      user.password = "password"
      user.save

  end


  5.times do
    board = Board.new
    board.name = Faker::Address.community
    board.user_id = User.all.sample.id
    board.save

    rand(10..50).times do
      post = Post.new
      post.user_id = User.all.sample.id
      post.board_id = board.id
      post.title = rand < 0.5 ? Faker::Commerce.product_name : Faker::Job.title
      post.body = Faker::Quotes::Shakespeare.hamlet_quote 
      post.created_at = Faker::Date.backward(days: 120)
      post.expires_on = post.created_at + rand(3..90).days
      post.save
    end
  end
  puts "There are now #{User.count} rows in the user table."
  puts "There are now #{Board.count} rows in the boards table."
  puts "There are now #{Post.count} rows in the posts table."
end
