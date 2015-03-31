class TestModel < ActiveRecord::Base
  def full_name
    "#{name} #{surname}"
  end

  def to_s
    full_name    
  end
end
