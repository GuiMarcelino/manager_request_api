# frozen_string_literal: true

# Para executar: load "teste_console.rb" ou rails runner teste_console.rb

# --- Setup ---
account = Account.first || Account.create!(name: "Conta Teste", cnpj: CNPJ.generate, active: true)
user = account.users.find_or_initialize_by(email: "usuario-console@teste.com").tap do |u|
  u.name ||= "Usuario Teste"
  u.role ||= :editor
  u.save!
end
admin_user = account.users.find_or_initialize_by(email: "admin-console@teste.com").tap do |u|
  u.name ||= "Admin Teste"
  u.role = :admin
  u.save!
end
category = account.categories.find_or_create_by!(name: "Categoria Teste") { |c| c.active = true }

# --- RequestCreator ---
result_creator = RequestManager::RequestCreator.call(
  account: account,
  user: user,
  title: "Solicitação X",
  category: category,
  description: "Opcional"
)
request = result_creator.payload
request_id = request&.id || 0

# --- RequestSubmitter ---
result_submitter = RequestManager::RequestSubmitter.call(account: account, id: request_id)

# --- RequestApprover ---
result_approver = RequestManager::RequestApprover.call(
  account: account,
  user: admin_user,
  id: request_id
)

# --- RequestRejector (outra request: criar e submeter antes de rejeitar) ---
result_creator2 = RequestManager::RequestCreator.call(
  account: account,
  user: user,
  title: "Solicitação Y",
  category: category,
  description: "Para testar rejeição"
)
request_id2 = result_creator2.payload&.id || 0
RequestManager::RequestSubmitter.call(account: account, id: request_id2) if request_id2.positive?
result_rejector = RequestManager::RequestRejector.call(
  account: account,
  id: request_id2,
  rejected_reason: "Razão teste rejeição"
)

puts "Creator: #{result_creator.success?} | Submitter: #{result_submitter.success?} | Approver: #{result_approver.success?} | Rejector: #{result_rejector.success?}"
