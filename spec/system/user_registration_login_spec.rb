require 'rails_helper'

RSpec.describe 'ユーザー登録・ログインのシステムテスト', type: :system do
  include Warden::Test::Helpers

  before { Warden.test_mode! }
  after { Warden.test_reset! }

  describe 'ユーザー登録' do
    it 'メールアドレスとパスワードを入力するとアカウントが作成され、自動ログインしてトップページに遷移する' do
      visit new_user_registration_path

      fill_in 'user[email]', with: 'new_user@example.com'
      fill_in 'user[password]', with: 'password123'
      fill_in 'user[password_confirmation]', with: 'password123'
      click_button 'アカウント登録'

      # 登録後は自動ログインされ、ログイン状態のトップページが表示される
      expect(page).to have_current_path(root_path)
      expect(page).to have_content 'こんにちは、new_user@example.com さん'
      expect(page).to have_link 'ログアウト'
    end
  end

  describe 'ログイン' do
    let!(:user) { create(:user) }

    it '登録済みユーザーはメールアドレスとパスワードでログインできる' do
      visit new_user_session_path

      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'

      expect(page).to have_current_path(root_path)
      expect(page).to have_content "こんにちは、#{user.email} さん"
      expect(page).to have_link 'ログアウト'
    end

    it '誤ったパスワードではログインできず、ログイン画面に留まる' do
      visit new_user_session_path

      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: 'wrongpass'
      click_button 'ログイン'

      expect(page).to have_current_path(new_user_session_path)
      expect(page).to have_content 'Eメールまたはパスワードが違います'
    end
  end

  describe 'ログアウト' do
    let!(:user) { create(:user) }

    it 'ログアウトするとトップページに戻り、未ログイン状態になる' do
      login_as user
      visit root_path
      expect(page).to have_content "こんにちは、#{user.email} さん"

      click_link 'ログアウト', match: :first

      expect(page).to have_current_path(root_path)
      expect(page).to have_no_content 'こんにちは'
      expect(page).to have_link '新規登録'
      expect(page).to have_link 'ログイン'
    end
  end
end
