require 'rspec'
require 'page-object'
require 'watir'

require 'data_magic'
require 'fig_newton'

require 'require_all'
require_all '../centric_shop/lib/pages'
require_all '../centric_shop/lib/panels'

World(PageObject::PageFactory)
