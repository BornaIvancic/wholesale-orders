# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password123"
  u.role = :admin
end
User.find_or_create_by!(email: "admin@example.com") do |u|
  u.password = "password123"
  u.role = :admin
end

company = Company.find_or_create_by!(name: "Demo Partner d.o.o.")

User.find_or_create_by!(email: "partner@example.com") do |u|
  u.password = "password123"
  u.role = :partner_user
  u.company = company
end

[
  { name: "Graševina 0.75L", sku: "GRA-075", price_cents: 890 },
  { name: "Malvazija 0.75L", sku: "MAL-075", price_cents: 990 },
  { name: "Plavac Mali 0.75L", sku: "PLA-075", price_cents: 1290 }
].each do |attrs|
  Product.find_or_create_by!(sku: attrs[:sku]) do |p|
    p.name = attrs[:name]
    p.price_cents = attrs[:price_cents]
    p.active = true
  end
end