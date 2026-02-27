# frozen_string_literal: true

module CommentManager
  # Service to list and filter comments.
  class CommentLister < ApplicationService
    def initialize(params)
      super()
      @ability = params[:ability]
      @active = params[:active]
    end

    def call
      return missing_service_parameter(:ability) if @ability.blank?

      list_comments
    end

    private

    def list_comments
      scope = Comment.accessible_by(@ability)
      scope = scope.by_active(@active) unless @active.nil?

      service_result(success: true, payload: scope)
    end
  end
end
