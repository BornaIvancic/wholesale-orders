# frozen_string_literal: true

require 'csv'

# =========================
# ADMIN KORISNICI
# =========================

User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password = 'password123'
  u.role = :admin
end

User.find_or_create_by!(email: 'a@a.a') do |u|
  u.password = '123456'
  u.role = :admin
end

# =========================
# IMPORT PROIZVODA IZ CSV-a
# =========================

file = Rails.root.join('db/import/products.csv')

rows = CSV.read(
  file,
  headers: true,
  encoding: 'bom|utf-8',
  liberal_parsing: true
)

puts "CSV headers: #{rows.headers.inspect}"

valid_products = rows.select do |row|
  name = row['Naziv'].to_s.strip
  price_raw = row['Normalna cijena'].to_s.strip
  type = row['Vrsta'].to_s.strip.downcase

  name.present? &&
    price_raw.present? &&
    price_raw != '0' &&
    type == 'simple'
end

puts "Valid products found: #{valid_products.size}"

selected = valid_products

Product.delete_all

products = selected.map.with_index do |row, i|
  price = row['Normalna cijena'].to_s.strip.tr(',', '.').to_f
  stock = row['Zalihe'].to_s.strip.to_i
  stock = rand(5..40) if stock <= 0

  csv_sku = row['SKU'].to_s.strip
  generated_sku = csv_sku.present? ? csv_sku : "VIVAT#{i.to_s.rjust(4, '0')}"

  {
    name: row['Naziv'].to_s.strip,
    sku: "#{generated_sku}-#{i}",
    price_cents: (price * 100).round,
    stock_quantity: stock,
    category: row['Kategorije'].to_s.split(',').first.to_s.strip,
    image_url: row['Slike'].to_s.split(',').first.to_s.strip,
    active: true,
    created_at: Time.current,
    updated_at: Time.current
  }
end

Product.insert_all!(products)

puts "Imported #{products.size} products from CSV"
puts "Users: #{User.count}, Companies: #{Company.count}, Products: #{Product.count}"

# =========================
# 50 PARTNER KOMPANIJA
# =========================

partner_companies_data = [
  { name: 'Adriatic Vino d.o.o.',        street_address: 'Ilica 15',                  postal_code: '10000', city: 'Zagreb',         oib: '10000000001' },
  { name: 'Aurora Trade d.o.o.',         street_address: 'Vukovarska 88',             postal_code: '10000', city: 'Zagreb',         oib: '10000000002' },
  { name: 'Barrique Partner d.o.o.',     street_address: 'Maksimirska 41',            postal_code: '10000', city: 'Zagreb',         oib: '10000000003' },
  { name: 'Bonavia Distribucija d.o.o.', street_address: 'Korzo 12',                  postal_code: '51000', city: 'Rijeka',         oib: '10000000004' },
  { name: 'Bura Vina d.o.o.',            street_address: 'Obala kneza Branimira 9',   postal_code: '23000', city: 'Zadar',          oib: '10000000005' },
  { name: 'Casta Vino d.o.o.',           street_address: 'Frankopanska 22',           postal_code: '10000', city: 'Zagreb',         oib: '10000000006' },
  { name: 'Cellar House d.o.o.',         street_address: 'Kapucinska 33',             postal_code: '42000', city: 'Varaždin',       oib: '10000000007' },
  { name: 'Central Wine Trade d.o.o.',   street_address: 'Ulica grada Vukovara 12',   postal_code: '10000', city: 'Zagreb',         oib: '10000000008' },
  { name: 'Dalmatia Selection d.o.o.',   street_address: 'Poljička cesta 20',         postal_code: '21000', city: 'Split',          oib: '10000000009' },
  { name: 'Decanter Partner d.o.o.',     street_address: 'Osječka 44',                postal_code: '31000', city: 'Osijek',         oib: '10000000010' },
  { name: 'Dioniz Trade d.o.o.',         street_address: 'Strossmayerova 8',          postal_code: '31000', city: 'Osijek',         oib: '10000000011' },
  { name: 'Divinum d.o.o.',              street_address: 'Gundulićeva 17',            postal_code: '10000', city: 'Zagreb',         oib: '10000000012' },
  { name: 'Enoteca Plus d.o.o.',         street_address: 'Zrinsko Frankopanska 5',    postal_code: '21000', city: 'Split',          oib: '10000000013' },
  { name: 'Estate Vino d.o.o.',          street_address: 'Matije Gupca 19',           postal_code: '43000', city: 'Bjelovar',       oib: '10000000014' },
  { name: 'Euro Vino Partner d.o.o.',    street_address: 'Radićeva 27',               postal_code: '10000', city: 'Zagreb',         oib: '10000000015' },
  { name: 'Fine Bottle d.o.o.',          street_address: 'Ulica Ivana Kukuljevića 9', postal_code: '42000', city: 'Varaždin',      oib: '10000000016' },
  { name: 'Golden Glass d.o.o.',         street_address: 'Savska cesta 101',          postal_code: '10000', city: 'Zagreb',         oib: '10000000017' },
  { name: 'Grand Cru Partner d.o.o.',    street_address: 'Riječka 28',                postal_code: '21000', city: 'Split',          oib: '10000000018' },
  { name: 'Grape Hub d.o.o.',            street_address: 'Kralja Tomislava 6',        postal_code: '35000', city: 'Slavonski Brod', oib: '10000000019' },
  { name: 'Heritage Wine d.o.o.',        street_address: 'Ante Starčevića 14',        postal_code: '23000', city: 'Zadar',          oib: '10000000020' },
  { name: 'Istra Select d.o.o.',         street_address: 'Carrarina 2',               postal_code: '52100', city: 'Pula',           oib: '10000000021' },
  { name: 'Jadran Vino Trade d.o.o.',    street_address: 'Riva 10',                   postal_code: '21000', city: 'Split',          oib: '10000000022' },
  { name: 'Kadulja Commerce d.o.o.',     street_address: 'Trg bana Jelačića 4',       postal_code: '10000', city: 'Zagreb',         oib: '10000000023' },
  { name: 'Korak Vino d.o.o.',           street_address: 'Trakošćanska 11',           postal_code: '42000', city: 'Varaždin',       oib: '10000000024' },
  { name: 'Kvarner Selection d.o.o.',    street_address: 'Ciottina 7',                postal_code: '51000', city: 'Rijeka',         oib: '10000000025' },
  { name: 'Lagunis d.o.o.',              street_address: 'Eufrazijeva 13',            postal_code: '52440', city: 'Poreč',          oib: '10000000026' },
  { name: 'Libra Vino d.o.o.',           street_address: 'Selska cesta 55',           postal_code: '10000', city: 'Zagreb',         oib: '10000000027' },
  { name: 'Lumen Trade d.o.o.',          street_address: 'Europske avenije 6',        postal_code: '31000', city: 'Osijek',         oib: '10000000028' },
  { name: 'Mare Distribution d.o.o.',    street_address: 'Put Supavla 3',             postal_code: '21000', city: 'Split',          oib: '10000000029' },
  { name: 'Merlot Partner d.o.o.',       street_address: 'Bakačeva 9',                postal_code: '10000', city: 'Zagreb',         oib: '10000000030' },
  { name: 'Monte Vino d.o.o.',           street_address: 'Ulica Stjepana Radića 18',  postal_code: '40000', city: 'Čakovec',        oib: '10000000031' },
  { name: 'Nobile Trade d.o.o.',         street_address: 'Kačićeva 21',               postal_code: '10000', city: 'Zagreb',         oib: '10000000032' },
  { name: 'North Cellar d.o.o.',         street_address: 'Koprivnička 30',            postal_code: '42000', city: 'Varaždin',       oib: '10000000033' },
  { name: 'Nova Berba d.o.o.',           street_address: 'Cvjetna cesta 5',           postal_code: '10000', city: 'Zagreb',         oib: '10000000034' },
  { name: 'Opus Vino d.o.o.',            street_address: 'Dubrovačka 7',              postal_code: '20000', city: 'Dubrovnik',      oib: '10000000035' },
  { name: 'Pelješac Partner d.o.o.',     street_address: 'Stonska 2',                 postal_code: '20250', city: 'Orebić',         oib: '10000000036' },
  { name: 'Premium Bottle d.o.o.',       street_address: 'Heinzelova 44',             postal_code: '10000', city: 'Zagreb',         oib: '10000000037' },
  { name: 'Primorska Vina d.o.o.',       street_address: 'Kumičićeva 16',             postal_code: '51000', city: 'Rijeka',         oib: '10000000038' },
  { name: 'Riviera Wine d.o.o.',         street_address: 'Šetalište Franje Tuđmana 8', postal_code: '23000', city: 'Zadar',        oib: '10000000039' },
  { name: 'Royal Glass d.o.o.',          street_address: 'Radnička cesta 52',         postal_code: '10000', city: 'Zagreb',         oib: '10000000040' },
  { name: 'Sommelier Partner d.o.o.',    street_address: 'Martićeva 67',              postal_code: '10000', city: 'Zagreb',         oib: '10000000041' },
  { name: 'Sparkling Point d.o.o.',      street_address: 'Gajeva 18',                 postal_code: '10000', city: 'Zagreb',         oib: '10000000042' },
  { name: 'Terra Vina d.o.o.',           street_address: 'Ante Kovačića 10',          postal_code: '42000', city: 'Varaždin',       oib: '10000000043' },
  { name: 'Vinaria Trade d.o.o.',        street_address: 'Palmotićeva 12',            postal_code: '10000', city: 'Zagreb',         oib: '10000000044' },
  { name: 'Vinoteka Partner d.o.o.',     street_address: 'Bosutska 14',               postal_code: '31000', city: 'Osijek',         oib: '10000000045' },
  { name: 'Vita Vino d.o.o.',            street_address: 'Kaštelanska 25',            postal_code: '21000', city: 'Split',          oib: '10000000046' },
  { name: 'Vivat Select d.o.o.',         street_address: 'Samoborska cesta 90',       postal_code: '10000', city: 'Zagreb',         oib: '10000000047' },
  { name: 'Zagorje Wine House d.o.o.',   street_address: 'Ljudevita Gaja 31',         postal_code: '49000', city: 'Krapina',        oib: '10000000048' },
  { name: 'Zlatna Kap d.o.o.',           street_address: 'Trg slobode 3',             postal_code: '31000', city: 'Osijek',         oib: '10000000049' },
  { name: 'Zora Distribucija d.o.o.',    street_address: 'Ulica kralja Petra Krešimira IV 6', postal_code: '35000', city: 'Slavonski Brod', oib: '10000000050' }
]

partner_companies = []

partner_companies_data.each_with_index do |attrs, i|
  email =
    if i.zero?
      'borna.ivancic23@gmail.com'
    else
      "partner#{i + 1}@winehub.test"
    end

  company = Company.find_or_create_by!(name: attrs[:name]) do |c|
    c.discount_percent = [0, 5, 10, 12, 15].sample
    c.payment_terms_days = [7, 14, 21, 30].sample
    c.offers_email = email
    c.street_address = attrs[:street_address]
    c.postal_code = attrs[:postal_code]
    c.city = attrs[:city]
    c.oib = attrs[:oib]
  end

  company.update!(
    street_address: attrs[:street_address],
    postal_code: attrs[:postal_code],
    city: attrs[:city],
    oib: attrs[:oib],
    offers_email: email
  )

  User.find_or_create_by!(email: email) do |u|
    u.password = 'password123'
    u.role = :partner_user
    u.company = company
  end

  partner_companies << company
end

# =========================
# ISPIS PARTNER PRISTUPNIH PODATAKA
# =========================

puts "\n=== PARTNER LOGIN PODACI ==="
partner_companies_data.each_with_index do |attrs, i|
  email =
    if i.zero?
      'borna.ivancic23@gmail.com'
    else
      "partner#{i + 1}@winehub.test"
    end

  puts "#{attrs[:name]} | OIB: #{attrs[:oib]} | #{attrs[:street_address]}, #{attrs[:postal_code]} #{attrs[:city]} | email: #{email} | password: password123"
end
puts "============================\n\n"

# =========================
# 200 TESTNIH NARUDŽBI
# =========================

partner_users = User.where(role: :partner_user).includes(:company).to_a
products_for_orders = Product.where(active: true).where("stock_quantity > 0").to_a
admin_user = User.where(role: :admin).first

status_pool = (
  [:draft] * 20 +
    [:submitted] * 40 +
    [:approved] * 30 +
    [:preparing] * 30 +
    [:shipped] * 20 +
    [:delivered] * 40 +
    [:rejected] * 10 +
    [:cancelled] * 10
).shuffle

200.times do |i|
  user = partner_users.sample
  company = user.company
  created_at_time = rand(120).days.ago

  order = Order.create!(
    company: company,
    created_by: user,
    status: status_pool[i],
    delivery_address: company.respond_to?(:full_address) ? company.full_address : [company.street_address, [company.postal_code, company.city].reject(&:blank?).join(' ')].reject(&:blank?).join(', '),
    notes: [
      "Molimo pažljivo zapakirati artikle.",
      "Isporuka u jutarnjim satima.",
      "Kontaktirati prije dostave.",
      "Standardna veleprodajna narudžba.",
      "Isporuka na stražnji ulaz objekta.",
      "Račun poslati elektroničkom poštom.",
      "Adresa dostave: #{company.respond_to?(:full_address) ? company.full_address : [company.street_address, [company.postal_code, company.city].reject(&:blank?).join(' ')].reject(&:blank?).join(', ')}",
      nil
    ].sample,
    created_at: created_at_time,
    updated_at: created_at_time
  )

  selected_products = products_for_orders.sample(rand(2..6))

  selected_products.each do |product|
    next if product.stock_quantity.to_i <= 0

    max_quantity = [product.stock_quantity, 12].min
    quantity = rand(1..max_quantity)

    unit_price_cents = product.price_cents
    line_total_cents = unit_price_cents * quantity

    OrderItem.create!(
      order: order,
      product: product,
      quantity: quantity,
      unit_price_cents: unit_price_cents,
      line_total_cents: line_total_cents
    )
  end

  if order.order_items.empty?
    order.destroy!
    next
  end

  Orders::RecalculateTotals.new(order: order).call

  case order.status.to_sym
  when :approved
    order.update_columns(
      approved_at: created_at_time + rand(1..3).days,
      updated_at: Time.current
    )
  when :preparing
    approved_at = created_at_time + rand(1..3).days
    order.update_columns(
      approved_at: approved_at,
      updated_at: Time.current
    )
  when :shipped
    approved_at = created_at_time + rand(1..3).days
    order.update_columns(
      approved_at: approved_at,
      updated_at: Time.current
    )
  when :delivered
    approved_at = created_at_time + rand(1..3).days
    delivered_at = approved_at + rand(2..7).days
    paid_at = [true, false].sample ? delivered_at + rand(1..10).days : nil

    order.update_columns(
      approved_at: approved_at,
      delivered_at: delivered_at,
      paid_at: paid_at,
      updated_at: Time.current
    )
  end

  case order.status.to_sym
  when :submitted
    OrderStatusHistory.create!(
      order: order,
      changed_by: user,
      from_status: Order.statuses[:draft],
      to_status: Order.statuses[:submitted],
      note: "Narudžba poslana od strane partnera."
    )
  when :approved
    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:submitted],
      to_status: Order.statuses[:approved],
      note: "Narudžba odobrena."
    )
  when :preparing
    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:submitted],
      to_status: Order.statuses[:approved],
      note: "Narudžba odobrena."
    )

    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:approved],
      to_status: Order.statuses[:preparing],
      note: "Započeta priprema robe."
    )
  when :shipped
    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:submitted],
      to_status: Order.statuses[:approved],
      note: "Narudžba odobrena."
    )

    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:approved],
      to_status: Order.statuses[:preparing],
      note: "Roba u pripremi."
    )

    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:preparing],
      to_status: Order.statuses[:shipped],
      note: "Narudžba poslana."
    )
  when :delivered
    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:submitted],
      to_status: Order.statuses[:approved],
      note: "Narudžba odobrena."
    )

    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:approved],
      to_status: Order.statuses[:preparing],
      note: "Roba u pripremi."
    )

    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:preparing],
      to_status: Order.statuses[:shipped],
      note: "Narudžba poslana."
    )

    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:shipped],
      to_status: Order.statuses[:delivered],
      note: "Narudžba isporučena."
    )
  when :rejected
    OrderStatusHistory.create!(
      order: order,
      changed_by: admin_user,
      from_status: Order.statuses[:submitted],
      to_status: Order.statuses[:rejected],
      note: "Narudžba odbijena."
    )
  when :cancelled
    OrderStatusHistory.create!(
      order: order,
      changed_by: user,
      from_status: Order.statuses[:draft],
      to_status: Order.statuses[:cancelled],
      note: "Narudžba otkazana."
    )
  end
end

puts "Generated #{Company.count} companies, #{User.count} users and #{Order.count} orders"