require_relative('../db/sql_runner')
require('Date')
require('time')

class User

  attr_reader :id
  attr_accessor :owner_first_name, :owner_last_name, :weekly_budget,
  :current_budget, :current_budget_date

  def initialize(details)
    if details['current_budget'] == nil
      @current_budget = details['weekly_budget'].to_f
    else
      @current_budget = details['current_budget'].to_f
    end

    @id = details['id'].to_i if details['id']
    @owner_first_name = details['owner_first_name']
    @owner_last_name = details['owner_last_name']
    @weekly_budget = details['weekly_budget'].to_f
    @current_budget_date = details['current_budget_date']
  end

  def save()
    sql = "INSERT INTO users
    (owner_first_name, owner_last_name, weekly_budget, current_budget, current_budget_date)
    VALUES ($1, $2, $3, $4, $5)
    RETURNING id "
    values = [@owner_first_name, @owner_last_name, @weekly_budget, @current_budget, @current_budget_date]
    result = SqlRunner.run(sql, values).first
    @id = result['id'].to_i
  end

  def update()
    sql = "UPDATE users
    SET (owner_first_name, owner_last_name, weekly_budget, current_budget, current_budget_date) =
    ($1, $2, $3, $4, $5)
    WHERE id = $6"
    values = [@owner_first_name, @owner_last_name, @weekly_budget, @current_budget, @current_budget_date, @id]
    SqlRunner.run(sql, values)
  end

  def delete()
    sql = "DELETE FROM users
    WHERE id = $1"
    values = [@id]
    SqlRunner.run(sql, values)
  end

  def pretty_name()
    "#{@owner_first_name} + #{@owner_last_name}"
  end

  def update_weekly_budget(amount)
    @weekly_budget += amount
    sql =  "UPDATE users
    SET weekly_budget = $1
    WHERE id = $2"
    values = [@weekly_budget, @id]
    SqlRunner.run(sql, values)
  end

  def update_current_budget(transaction)
    result = @current_budget -= transaction.gbp_amount
    self.update()
  end

  def update_current_budget_on_delete(transaction)
    if in_budget_date?(transaction) == true
      @current_budget += transaction.gbp_amount
      sql =  "UPDATE users
      SET current_budget = $1
      WHERE id = $2"
      values = [@current_budget, @id]
      SqlRunner.run(sql, values)
    else
      return
    end
  end

  def budget_is_reaching_limit?
    @current_budget <= 100
  end

  def end_of_week_money?
    @current_budget > 0
  end

  def in_budget_date?(transaction)
    current_budget = Time.parse(@current_budget_date)
    end_budget = current_budget + 604800
    transaction_date = Time.parse(transaction.time_stamp.to_s)
    transaction_date.between?(current_budget, end_budget)
  end

  def set_time_stamp
    budget_time =  Time.now()
    budget_date = budget_time.to_s[0,10]
    @current_budget_date = Time.parse(budget_date)
    sql = "UPDATE users
    SET current_budget_date = $1
    WHERE id = $2"
    values = [@current_budget_date, @id]
    SqlRunner.run(sql, values)
  end

  def end_of_week
    set_time_stamp
    @current_budget = @weekly_budget
    self.update()
    values = [@current_budget, @id]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM users
    WHERE name = $1"
    values = [name]
    found_user = SqlRunner.run(sql, values)
    return User.new(found_user.first)
  end

  def self.find_by_id(id)
    sql = "SELECT * FROM users
    WHERE id = $1"
    values = [id]
    found_user = SqlRunner.run(sql, values)
    result = User.new(found_user.first)
  end

  def self.map_users(user_info)
    result = user_info.map {|user| User.new(user)}
    return result
  end

  def self.all()
    sql = "SELECT * FROM users"
    users = SqlRunner.run(sql)
    result = User.map_users(users)
  end

  def self.delete_all()
    sql = "DELETE FROM users"
    SqlRunner.run(sql)
  end


end
