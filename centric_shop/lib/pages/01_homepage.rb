# Home Page of the Centric Shopping Store

require_all 'lib'
class HomePage < ShopBasePage

  page_url FigNewton.test_env

  expected_element_visible(:header_logo, 30)
  div(:header_logo, class: 'header-logo')

  def initialize_page
    has_expected_element_visible?
  end
end
