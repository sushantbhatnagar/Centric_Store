class Register < ShopBasePage

  radio_button(:male, id: 'gender-male')
  radio_button(:female, id: 'gender-female')
  text_field(:first_name, id: 'FirstName')
  text_field(:last_name, id: 'LastName')
  select_list(:day, name: 'DateOfBirthDay')
  select_list(:month, name: 'DateOfBirthMonth')
  select_list(:year, name: 'DateOfBirthYear')
  text_field(:email, id: 'Email')
  text_field(:company, id: 'Company')
  text_field(:password, id: 'Password')
  text_field(:confirm_password, id: 'ConfirmPassword')
  button(:register_confirm, id: 'register-button')

  div(:registeration_success, class: 'result')

  def input_details_to_register
    select_male
    populate_page_with data_for(:registeration_details)
    register_confirm
  end
end
