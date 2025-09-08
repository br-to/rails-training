RSpec.describe ApiToken, type: :model do
  let(:user) { create(:user) }

  describe ".generate_for" do
    it "新しいAPIトークンを生成する" do
      expect {
        ApiToken.generate_for(user)
      }.to change(ApiToken, :count).by(1)
    end

    it "token_形式の平文トークンを返す" do
      plain_token = ApiToken.generate_for(user)
      expect(plain_token).to match(/\Atoken_\d+\..+\z/)
    end

    it "token_digestにハッシュ化された値を保存する" do
      plain_token = ApiToken.generate_for(user)
      api_token = ApiToken.last

      expect(api_token.token_digest).to be_present
      expect(api_token.token_digest).not_to include(plain_token)
    end

    it "生成されたトークンでfind_by_tokenできる" do
      plain_token = ApiToken.generate_for(user)
      found_token = ApiToken.find_by_token(plain_token)

      expect(found_token).to be_present
      expect(found_token.user).to eq(user)
    end
  end

  describe ".find_by_token" do
    let(:plain_token) { ApiToken.generate_for(user) }
    let(:api_token) { ApiToken.find_by_token(plain_token) }

    context "有効なトークン" do
      it "対応するApiTokenを返す" do
        expect(api_token).to be_present
        expect(api_token.user).to eq(user)
        expect(api_token.active?).to be_truthy
      end
    end

    context "無効なフォーマット" do
      it "nilを返す" do
        expect(ApiToken.find_by_token("invalid_format")).to be_nil
        expect(ApiToken.find_by_token("token_")).to be_nil
        expect(ApiToken.find_by_token("nottoken_123.secret")).to be_nil
      end
    end

    context "存在しないID" do
      it "nilを返す" do
        expect(ApiToken.find_by_token("token_99999.secret")).to be_nil
      end
    end

    context "間違ったsecret" do
      it "nilを返す" do
        wrong_token = plain_token.gsub(/\..*$/, '.wrong_secret')
        expect(ApiToken.find_by_token(wrong_token)).to be_nil
      end
    end
  end

  describe "#revoke!" do
    let(:plain_token) { ApiToken.generate_for(user) }
    let(:api_token) { ApiToken.find_by_token(plain_token) }

    it "revoked_atに現在時刻を設定する" do
      expect {
        api_token.revoke!
      }.to change { api_token.revoked_at }.from(nil)

      expect(api_token.revoked_at).to be_within(1.second).of(Time.current)
    end
  end

  describe "#active?" do
    let(:plain_token) { ApiToken.generate_for(user) }
    let(:api_token) { ApiToken.find_by_token(plain_token) }

    it "revoked_atがnilの場合はtrueを返す" do
      expect(api_token.active?).to be_truthy
    end

    it "revoke!後はfalseを返す" do
      api_token.revoke!
      expect(api_token.active?).to be_falsey
    end
  end
end
