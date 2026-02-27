# frozen_string_literal: true

# Defines authorization rules per user role.
# - admin: full access within account
# - editor: create, submit, comment (no approve/reject/destroy)
# - viewer: read-only
class Ability
  include CanCan::Ability

  def initialize(user)
    return if user.blank?

    account_id = user.account_id

    case user.role.to_sym
    when :admin
      can :manage, Request, account_id: account_id
      can :manage, Comment, account_id: account_id
    when :editor
      can %i[read create], Request, account_id: account_id
      can :submit, Request, account_id: account_id, status: 'draft'
      can %i[read create], Comment, account_id: account_id
    when :viewer
      can :read, Request, account_id: account_id
      can :read, Comment, account_id: account_id
    end
  end
end
