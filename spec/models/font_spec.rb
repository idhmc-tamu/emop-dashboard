require 'rails_helper'

RSpec.describe Font, :type => :model do
  let(:font) { create(:font) }

  it "is valid" do
    expect(font).to be_valid
  end

  describe 'ActiveModel validations' do
    it { expect(font).to validate_presence_of(:font_name) }
  end

  describe "to_builder" do
    it "has valid to_builder - v1" do
      json = font.to_builder('v1').attributes!
      expect(json).to match(
        'id'                => font.id,
        'font_name'         => font.font_name,
        'font_italic'       => font.font_italic,
        'font_bold'         => font.font_bold,
        'font_fixed'        => font.font_fixed,
        'font_serif'        => font.font_serif,
        'font_fraktur'      => font.font_fraktur,
        'font_line_height'  => font.font_line_height,
        'font_library_path' => font.font_library_path,
      )
    end

    it "has valid to_builder - v2" do
      json = font.to_builder('v2').attributes!
      expect(json).to match(
      'id'                => font.id,
      'font_name'         => font.font_name,
      'font_italic'       => font.font_italic,
      'font_bold'         => font.font_bold,
      'font_fixed'        => font.font_fixed,
      'font_serif'        => font.font_serif,
      'font_fraktur'      => font.font_fraktur,
      'font_line_height'  => font.font_line_height,
      'font_library_path' => font.font_library_path,
      'path'              => font.path,
      )
    end
  end

  describe 'traineddata_path' do
    it 'should set a path' do
      allow(Rails.application.secrets).to receive(:emop_font_dir) { "/dne" }
      allow(Settings).to receive(:font_suffix) { ".foo" }
      expected = File.join('/dne', "#{font.font_name}.foo")
      expect(font.traineddata_path).to eq(expected)
    end
  end
end