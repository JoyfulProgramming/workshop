require 'rails_helper'

RSpec.describe Pattern, type: :model do
  describe ".from_fcjson" do
    it "creates a pattern with a preview image from FCJSON" do
      fcjson_data = File.read(Rails.root.join("spec/support/example.fcjson"))

      pattern = Pattern.from_fcjson(fcjson_data)
      expect(pattern).to be_a(Pattern)
      expect(pattern.preview).to be_attached
      expect(pattern.preview.content_type).to start_with("image/")
      expect(pattern.preview).to be_attached
      preview_image = MiniMagick::Image.read(pattern.preview.download)
      expect(preview_image.width).to eq(2 * 32)
      expect(preview_image.height).to eq(2 * 32)
      expect(pattern.name).to eq("Testing")
    end
  end
end
