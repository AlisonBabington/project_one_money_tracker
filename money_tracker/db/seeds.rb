require_relative('../models/accounts.rb')
require_relative('../models/merchants.rb')
require_relative('../models/transactions.rb')
require_relative('../models/tags.rb')

require('pry-byebug')


Tag.delete_all()
Merchant.delete_all()

tag1 = Tag.new({"name" => "Groceries"})
tag1.save()

tag2 = Tag.new({"name" => "Entertainment"})
tag2.save()

merchant1 = Merchant.new({"name" => "Waitrose"})
merchant1.save()

merchant2 = Merchant.new({"name" => "Dominion Cinema"})
merchant2.save()

merchant3 = Merchant.new({"name" => "Footlights"})
merchant3.save()

tags = Tag.all
merchants = Merchant.all

binding.pry
nil
