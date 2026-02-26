# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestManager::RequestRejector, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:rejected_reason) { "Documentação incompleta" }
  let(:request) do
    create(:request, account: account, user: user, category: create(:category, account: account), status: :pending_approval)
  end

  describe "#call" do
    subject do
      described_class.new(account: account, id: request.id, rejected_reason: rejected_reason).call
    end

    context "when rejected_reason is present" do
      it { is_expected.to be_success }

      it "returns the request as payload" do
        expect(subject.payload).to eq request.reload
      end

      it "sets decided_at" do
        expect { subject }.to change { request.reload.decided_at }.from(nil)
      end

      it "sets rejected_reason" do
        expect { subject }.to change { request.reload.rejected_reason }.from(nil).to(rejected_reason)
      end
    end

    context "when rejected_reason is blank" do
      let(:rejected_reason) { "" }

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end
    end

    context "when rejected_reason is nil" do
      subject do
        described_class.new(account: account, id: request.id).call
      end

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end
    end

    context "when request does not belong to account" do
      let(:other_account) { create(:account) }

      subject do
        described_class.new(account: other_account, id: request.id, rejected_reason: rejected_reason).call
      end

      it { is_expected.not_to be_success }

      it "returns a 404 error code" do
        expect(subject.errors[:code]).to eq 404
      end
    end

    context "when request does not exist" do
      subject do
        described_class.new(account: account, id: 0, rejected_reason: rejected_reason).call
      end

      it { is_expected.not_to be_success }

      it "returns a 404 error code" do
        expect(subject.errors[:code]).to eq 404
      end
    end
  end
end
