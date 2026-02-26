# db/seeds.rb

ActiveRecord::Base.transaction do
  puts "Seeding database..."

  # =========================
  # Account
  # =========================
  account = Account.find_or_initialize_by(cnpj: "94.984.296/0001-76")

  account.update!(
    name: "Account Seed",
    active: true
  )

  # =========================
  # Users
  # =========================
  users_data = [
    { email: "viewer@example.com", role: :viewer, name: "Viewer User" },
    { email: "editor@example.com", role: :editor, name: "Editor User" },
    { email: "admin@example.com",  role: :admin,  name: "Admin User" }
  ]

  users = users_data.map do |data|
    user = User.find_or_initialize_by(account: account, email: data[:email])

    user.update!(
      name: data[:name],
      role: data[:role]
    )

    user
  end

  %w[Hardware Software Financeiro RH].each do |category_name|
    category = Category.find_or_initialize_by(
      account: account,
      name: category_name
    )

    category.update!(active: true)
  end

  puts <<~MSG
    Seed completed:
      Account: #{account.id}
      Users: #{users.map { |u| "#{u.role}(#{u.id})" }.join(", ")}
      Categories: #{account.categories.pluck(:name).join(", ")}
  MSG
end