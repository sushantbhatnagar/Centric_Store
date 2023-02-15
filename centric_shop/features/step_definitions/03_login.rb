When(/^I login to the website$/) do
  on(LoginPage) do |page|
    page.login
    page.login_credentials
  end
end