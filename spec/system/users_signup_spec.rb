require "rails_helper"

RSpec.describe "UsersSignup", type: :system, js: true do
  describe "normal sign up" do
    subject {
      visit new_user_registration_path
      fill_in "Username", with: username
      fill_in "Profile", with: profile
      fill_in "Email", with: email
      attach_file "user_image", "#{Rails.root}/spec/factories/rails.png"
      fill_in "Password", with: password
      fill_in "Password confirmation", with: password_confirmation
      click_on "Sign up"
    }
    context "try to sign up by invalid user info" do
      let(:username) { "" }
      let(:profile) { "" }
      let(:email) { "user@invalid" }
      let(:password) { "foo" }
      let(:password_confirmation) { "bar" }
      it "should not increase user count and raise error" do
        expect { subject }.to change { User.count }.by(0)
        expect(page).to have_css "#error_explanation"
      end
    end

    context "try to sign up by valid user info" do
      let(:username) { "test_user" }
      let(:profile) { "This is test_user profile." }
      let(:email) { "user@example.com" }
      let(:password) { "password" }
      let(:password_confirmation) { "password" }
      it "should increase user count and redirect to root_path" do
        expect { subject }.to change { User.count }.by(1)
        expect(current_path).to eq root_path
      end
    end
  end
end