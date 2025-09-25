RSpec.describe MyJob, type: :job do
  describe '#perform' do
    context "成功時" do
      it "ジョブが正常に完了すること" do
        expect {
          MyJob.perform_now("success")
        }.not_to raise_error
      end

      it "Articleにログが作成されること" do
        expect { described_class.perform_now('success') }.to change(Article, :count).by(1)
      end
    end

    context "一時的なエラー発生時" do
      it "TemporaryExternalErrorが発生すること" do
        expect {
          described_class.perform_now('temporary_failure')
        }.to raise_error(TemporaryExternalError, "API timeout")
      end
    end

    context "永続的なエラー発生時" do
      it "PermanentExternalErrorが発生すること" do
        expect {
          described_class.perform_now('permanent_failure')
        }.to raise_error(PermanentExternalError, "Invalid request")
      end
    end

    context "冪等性テスト" do
      it "同じjob_idで複数回実行してもArticleが重複しないこと" do
        job = MyJob.new
        job_id = SecureRandom.uuid

        allow(job).to receive(:job_id).and_return(job_id)

        expect {
          job.perform("success")
        }.to change(Article, :count).by(1)

        expect {
          job.perform("success")
        }.not_to change(Article, :count)
      end
    end
  end
end
