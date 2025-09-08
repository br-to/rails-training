RSpec.describe User, type: :model do
  describe "validations" do
    it "有効な属性で作成できる" do
      user = build(:user)
      expect(user).to be_valid
    end

    describe "email" do
      it "必須項目である" do
        user = build(:user, email: nil)
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("can't be blank")
      end

      it "ユニークである必要がある" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "test@example.com")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("has already been taken")
      end

      it "大文字小文字を区別せずユニークである" do
        create(:user, email: "test@example.com")
        user = build(:user, email: "TEST@example.com")
        expect(user).not_to be_valid
        expect(user.errors[:email]).to include("has already been taken")
      end

        it '有効なメールアドレス形式である必要がある' do
          invalid_emails = ['plainaddress', '@missingusername.com', 'username@.com', 'username@']
          invalid_emails.each do |invalid_email|
            user = build(:user, email: invalid_email)
            expect(user).not_to be_valid, "#{invalid_email} should be invalid"
          end
        end

        it "保存時に小文字に変換される" do
        user = create(:user, email: "TEST@Example.COM")
        expect(user.email).to eq("test@example.com")
      end
    end

    describe "name" do
      it "必須項目である" do
        user = build(:user, name: nil)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("can't be blank")
      end

      it "空文字は無効" do
        user = build(:user, name: "")
        expect(user).not_to be_valid
      end

      it "50文字以下である必要がある" do
        user = build(:user, name: "a" * 51)
        expect(user).not_to be_valid
        expect(user.errors[:name]).to include("is too long (maximum is 50 characters)")
      end

      it "50文字以下なら有効" do
        user = build(:user, name: "a" * 50)
        expect(user).to be_valid
      end
    end
  end

  describe "associations" do
    it "api_tokensとhas_many関係を持つ" do
      association = User.reflect_on_association(:api_tokens)
      expect(association.macro).to eq(:has_many)
      expect(association.options[:dependent]).to eq(:destroy)
    end

    it "ユーザー削除時にapi_tokensも削除される" do
      user = create(:user)
      api_token = create(:api_token, user: user)

      expect {
        user.destroy
      }.to change(ApiToken, :count).by(-1)
    end
  end
end
