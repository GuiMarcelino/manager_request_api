# frozen_string_literal: true

require "rails_helper"

RSpec.describe RequestManager::RequestSubmitter, type: :service do
  let(:account) { create(:account) }
  let(:user) { create(:user, account: account) }
  let(:request) { create(:request, account: account, user: user, category: create(:category, account: account), status: :draft) }

  describe "#call" do
    subject do
      described_class.new(account: account, id: request.id).call
    end

    context "when request is in draft status" do
      it { is_expected.to be_success }

      it "returns the request as payload" do
        expect(subject.payload).to eq request.reload
      end

      it "transitions to pending_approval" do
        expect { subject }.to change { request.reload.status }.from("draft").to("pending_approval")
      end

      it "sets submitted_at" do
        expect { subject }.to change { request.reload.submitted_at }.from(nil)
      end
    end

    context "when request is already submitted" do
      before { request.update!(status: :pending_approval) }

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end
    end

    context "when request is approved" do
      before { request.update!(status: :approved) }

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end
    end

    context "when request is rejected" do
      before { request.update!(status: :rejected) }

      it { is_expected.not_to be_success }

      it "returns a 422 error code" do
        expect(subject.errors[:code]).to eq 422
      end
    end

    context "when request does not belong to account" do
      let(:other_account) { create(:account) }

      subject do
        described_class.new(account: other_account, id: request.id).call
      end

      it { is_expected.not_to be_success }

      it "returns a 404 error code" do
        expect(subject.errors[:code]).to eq 404
      end
    end

    context "when request does not exist" do
      subject do
        described_class.new(account: account, id: 0).call
      end

      it { is_expected.not_to be_success }

      it "returns a 404 error code" do
        expect(subject.errors[:code]).to eq 404
      end
    end
  end
end
