class TestModel < ActiveRecord::Base
  attr_accessible :email_address, :extra_id, :name, :surname

  def full_name
    "#{name} #{surname}"
  end
end
