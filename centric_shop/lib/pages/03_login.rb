require_all 'lib'
class LoginPage < ShopBasePage

  text_field(:email, id: 'Email')
  text_field(:password, id: 'Password')
  button(:enter_into_website, class: 'login-button')

  def login_credentials
    populate_page_with data_for(:login_creds)
    enter_into_website
  end
end
