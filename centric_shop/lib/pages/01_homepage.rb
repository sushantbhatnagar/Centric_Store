# Home Page of the Centric Shopping Store
class HomePage < ShopBasePage
  include FigNewton

  page_url FigNewton.base_url

  expected_element_visible(:header_logo, 30)
  div(:header_logo, class: 'header-logo')

  def initialize_page
    has_expected_element_visible?
  end
end
