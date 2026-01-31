class CreateOffers < ActiveRecord::Migration[8.1]
  def change
    create_table :offers do |t|
      t.references :order, null: false, foreign_key: true
      t.string :number
      t.string :sent_to_email
      t.datetime :sent_at

      t.timestamps
    end
  end
end
