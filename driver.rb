require_relative 'models/user'
require_relative 'models/inventory'
require_relative 'models/item'
require_relative 'services/search_by_availability_service'

class Driver
  attr_accessor :inventory, :purge_threshold

  def initialize()
    @inventory = Inventory.new
    @users = {}
    @search_service = SearchByAvailabilityService.new(inventory)
  end

  def add_to_inventory(item: , quantity: )
    @inventory.add_item(item: item, quantity: quantity)
  end

  def add_user(name: , address: , wallet_amount: )
    user = User.new(name: name, address: address, wallet_amount: wallet_amount)
    @users[user.id] = user
  end

  def get_cart_info(user_id: )
    cart = @users[user_id].cart
    if cart.size < 1
      puts "CART EMPTY"
      return
    end

    cart.each do |item_id, quantity|
      puts "ITEM: #{@inventory.all_items[item_id].to_s}     QUANTITY: #{quantity}"
    end
  end

  def remove_from_cart(user_id:, item: , quantity: )
    user = @users[user_id]

    user.remove_from_cart(item: item, quantity: quantity)
    @inventory.retract_order(item: item, quantity: quantity)
  end

  def add_item_to_cart(user_id: , item: , quantity: )
    user = @users[user_id]

    raise StandardError "Unknown Item id" unless @inventory.has_item?(item_id: item.id)

    puts "QUANTITY should be positive" if quantity < 1

    order_cost = @inventory.all_items[item.id].price * quantity

    if !@inventory.can_fulfil_order?(item: item, quantity: quantity)
      puts "Inventory can't fulfill the order"
      @inventory.list_stock_status
      return
    end

    return unless user.wallet.has_sufficient_funds?(order_cost)

    user.add_to_cart(item: item, quantity: quantity)
    @inventory.promise_order(item: item, quantity: quantity)
  end

  def search(brand: nil, category: nil, quantity: nil, price: nil, rating: nil)
    @search_service.search(brand: brand, category: category, quantity: quantity, price: price, rating: rating)
  end
end




# Models
  + User
  + Event

# actions
  + user create event
  + user add other user as part of event
  + user update rsvp value for an event[Y,N,Maybe]
  + choose to attend, -> overalpping events are updated rsvp as no

# functions

Notes:
 + basic validations can be assumed and implemented










# require_relative 'lib/flipkart_daily/driver'


# require_relative 'driver'
# require_relative 'models/user'
# require_relative 'models/inventory'
# require_relative 'models/item'

# driver = Driver.new()

# item_1 = Item.new(category: "C1", brand: "B1", price: 20 , rating: 4.5)
# item_2 = Item.new(category: "C1", brand: "B2", price: 30 , rating: 4.5)
# item_3 = Item.new(category: "C1", brand: "B3", price: 2000 , rating: 4.5)
# item_4 = Item.new(category: "C1", brand: "B4", price: 400 , rating: 4.5)
# item_5 = Item.new(category: "C1", brand: "B5", price: 50 , rating: 4.5)
# item_6 = Item.new(category: "C2", brand: "B1", price: 60 , rating: 4.5)


# item_7 = Item.new(category: "C3", brand: "B1", price: 55 , rating: 4.5)
# item_8 = Item.new(category: "C4", brand: "B1", price: 2 , rating: 4.5)
# item_9 = Item.new(category: "C5", brand: "B1", price: 45 , rating: 4.5)

# user = driver.add_user(name: "U1" , address:"adfs" , wallet_amount: 500)

# user_2 = driver.add_user(name: "U2" , address:"adfs" , wallet_amount: 100)

# driver.get_cart_info(user_id: user.id)

# driver.get_cart_info(user_id: user_2.id)

# driver.add_to_inventory(item: item_1, quantity: 10)
# driver.add_to_inventory(item: item_2, quantity: 25)
# driver.add_to_inventory(item: item_3, quantity: 40)
# driver.add_to_inventory(item: item_4, quantity: 4)
# driver.add_to_inventory(item: item_5, quantity: 3)
# driver.add_to_inventory(item: item_6, quantity: 2)

# # driver.inventory.all_items

# driver.inventory.list_stock_status

# user.wallet.add(amount: 1000)

# driver.add_item_to_cart(user_id: user.id, item: item_1, quantity: 7)


# driver.add_item_to_cart(user_id: user_2.id, item: item_1, quantity: 3)

# driver.add_item_to_cart(user_id: user.id, item: item_4, quantity: 2)

# # user.remove_from_cart(item: item_1, quantity: 1)

# driver.remove_from_cart(user_id: user.id, item: item_1, quantity: 1)
# driver.remove_from_cart(user_id: user.id, item: item_5, quantity: 4)

# driver.add_item_to_cart(user_id: user.id, item: item_2, quantity: 3)

# driver.add_item_to_cart(user_id: user.id, item: item_5, quantity: 3)

# driver.search(brand: nil, category: nil, quantity: nil, price: nil, rating: nil)

# driver.search(brand: "B1", category: nil, quantity: 2, price: nil, rating: nil)
# driver.search(brand: "B6", category: nil, quantity: 2, price: nil, rating: nil)

# driver.search(brand: "B2", category: "C1", quantity: 20, price: nil, rating: nil)

# driver.search(brand: "B2", category: "C1", quantity: 20, price: nil, rating: nil)

