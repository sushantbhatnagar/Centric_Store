require 'spec_helper'
require 'page-object'

describe 'Landing Page of the Centric Shopping Store' do
  it 'show display a Centric Logo' do
    visit HomePage
    expect(on(HomePage).header_logo_element).to exist
  end
end
