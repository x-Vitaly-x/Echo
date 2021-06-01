class CreateEndpoints < ActiveRecord::Migration[6.1]
  def change
    create_table :endpoints, id: :uuid do |t|
      t.string :path
      t.string :verb
      t.jsonb :response
      t.timestamps
    end
  end
end
