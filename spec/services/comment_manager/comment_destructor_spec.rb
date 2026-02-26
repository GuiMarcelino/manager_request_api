# frozen_string_literal: true

require "rails_helper"

RSpec.describe CommentManager::CommentDestructor, type: :service do
  let(:account) { create(:account) }
  let(:author) { create(:user, account: account) }
  let(:request) { create(:request, account: account, user: author, category: create(:category, account: account)) }
  let(:comment) { create(:comment, account: account, request: request, user: author) }

  before { comment }

  describe "#call" do
    context "when user is the author" do
      subject do
        described_class.new(account: account, user: author, id: comment.id).call
      end

      it { is_expected.to be_success }

      it "returns the comment as payload" do
        expect(subject.payload).to eq comment
      end

      it "destroys the comment" do
        expect { subject }.to change(Comment, :count).by(-1)
      end
    end

    context "when user is admin" do
      let(:admin_user) { create(:user, account: account, role: :admin) }

      subject do
        described_class.new(account: account, user: admin_user, id: comment.id).call
      end

      it { is_expected.to be_success }

      it "destroys the comment" do
        expect { subject }.to change(Comment, :count).by(-1)
      end
    end

    context "when user is not author and not admin" do
      let(:other_user) { create(:user, account: account, role: :editor) }

      subject do
        described_class.new(account: account, user: other_user, id: comment.id).call
      end

      it { is_expected.not_to be_success }

      it "returns a 403 error code" do
        expect(subject.errors[:code]).to eq 403
      end

      it "does not destroy the comment" do
        expect { subject }.not_to change(Comment, :count)
      end
    end

    context "when comment does not belong to account" do
      let(:other_account) { create(:account) }
      let(:admin_user) { create(:user, account: account, role: :admin) }

      subject do
        described_class.new(account: other_account, user: admin_user, id: comment.id).call
      end

      it { is_expected.not_to be_success }

      it "returns a 404 error code" do
        expect(subject.errors[:code]).to eq 404
      end
    end

    context "when comment does not exist" do
      let(:admin_user) { create(:user, account: account, role: :admin) }

      subject do
        described_class.new(account: account, user: admin_user, id: 0).call
      end

      it { is_expected.not_to be_success }

      it "returns a 404 error code" do
        expect(subject.errors[:code]).to eq 404
      end
    end
  end
end
