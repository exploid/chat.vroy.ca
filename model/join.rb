unless DB.table_exists? :joins
  DB.create_table :joins do
    primary_key :id
    Fixnum :room_id
    Fixnum :user_id
  end
  DB.add_index :joins, [:room_id, :user_id], :unique => true
end

class Join < Sequel::Model
end
