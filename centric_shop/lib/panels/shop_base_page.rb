# Base Page of the Shopping Store
class ShopBasePage
  include PageObject
  include DataMagic
  include FigNewton

  link(:register, class: 'ico-register')
  link(:login, class: 'ico-login')

end
