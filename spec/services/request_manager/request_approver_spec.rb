# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestManager::RequestApprover, type: :service do
  let(:account) { create(:account) }
  let(:admin_user) { create(:user, account: account, role: :admin) }
  let(:request) do
    create(:request, account: account, user: admin_user, category: create(:category, account: account), status: :pending_approval)
  end

  describe "#call" do
    subject do
      described_class.new(account: account, user: admin_user, id: request.id).call
    end

    context "when user is admin" do
      it { is_expected.to be_success }

      it "returns the request as payload" do
        expect(subject.payload).to eq request.reload
      end

      it "sets decided_at" do
        expect { subject }.to change { request.reload.decided_at }.from(nil)
      end
    end

    context "when user is not admin" do
      let(:editor_user) { create(:user, account: account, role: :editor) }

      subject do
        described_class.new(account: account, user: editor_user, id: request.id).call
      end

      it { is_expected.not_to be_success }

      it "returns a 403 error code" do
        expect(subject.errors[:code]).to eq 403
      end
    end

    context "when user is viewer" do
      let(:viewer_user) { create(:user, account: account, role: :viewer) }

      subject do
        described_class.new(account: account, user: viewer_user, id: request.id).call
      end

      it { is_expected.not_to be_success }

      it "returns a 403 error code" do
        expect(subject.errors[:code]).to eq 403
      end
    end

    context "when request does not belong to account" do
      let(:other_account) { create(:account) }

      subject do
        described_class.new(account: other_account, user: admin_user, id: request.id).call
      end

      it { is_expected.not_to be_success }

      it "returns a 404 error code" do
        expect(subject.errors[:code]).to eq 404
      end
    end

    context "when request does not exist" do
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
