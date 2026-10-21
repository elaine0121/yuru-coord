require 'rails_helper'

RSpec.describe 'ユーザー登録・ログインのシステムテスト', type: :system do
  # 真实 Chrome(Selenium) 下这些表单提交偶发不稳定（CI 上登录/注册偶发失败）。
  # 本文件只验证"填表→提交→跳转"逻辑，不涉及 JS 交互，改用 rack_test 稳定驱动即可保证 CI 稳定。
  around do |example|
    Capybara.using_driver(:rack_test) do
      example.run
    ensure
      # 每个测试结束后强制清空浏览器会话(cookie)，
      # 避免上一个测试残留的登录态在随机执行顺序下污染下一个测试（CI 偶发红根因）
      Capybara.reset_sessions!
    end
  end

  before do
    Capybara.reset_sessions!
  end

  describe 'ユーザー登録' do
    it 'メールアドレスとパスワードを入力するとアカウントが作成され、自動ログインしてトップページに遷移する' do
      visit new_user_registration_path

      fill_in 'user[email]', with: 'new_user@example.com'
      fill_in 'user[password]', with: 'password123'
      fill_in 'user[password_confirmation]', with: 'password123'
      click_button 'アカウント登録'

      # 登録後は自動ログインされ、ログイン状態のトップページが表示される
      # 先等"登录成功后才出现的欢迎语"，页面渲染完成后再确认跳转
      expect(page).to have_content 'こんにちは、new_user@example.com さん', wait: 15
      expect(page).to have_current_path(root_path)
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

      expect(page).to have_link 'ログアウト', wait: 15
      expect(page).to have_current_path(root_path)
      expect(page).to have_content "こんにちは、#{user.email} さん"
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
      visit new_user_session_path

      fill_in 'user[email]', with: user.email
      fill_in 'user[password]', with: user.password
      click_button 'ログイン'
      # 登录成功后先等"登出链接"出现，确认已登录再继续
      expect(page).to have_link 'ログアウト', wait: 15

      click_link 'ログアウト', match: :first

      expect(page).to have_current_path(root_path, wait: 10)
      expect(page).to have_no_content 'こんにちは'
      expect(page).to have_link '新規登録'
      expect(page).to have_link 'ログイン'
    end
  end
end
