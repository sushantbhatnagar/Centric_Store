Given(/^I land on the shopping website homepage$/) do
  visit(HomePage)
end

When(/^I register myself on the website$/) do
  on(Register) do |page|
    page.register
    page.input_details_to_register
  end
end

Then(/^I should be able to below registration successful text$/) do |text|
  #TODO: sleep to be converted into robust_wait/ajax calls
  sleep 5
  expect(on(Register).registeration_success_element.text).to eql (text)
end

When(/^I navigate to Register page$/) do
  on(Register) do |page|
    page.register
  end
end

Then(/^I should see on the page$/) do |text|
  expect(on(Register).register_header_element.text).to eql (text)
end