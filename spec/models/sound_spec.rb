require 'spec_helper'

describe "Sound Model" do
  let(:sound) { Sound.new }
  it 'can be created' do
    sound.should_not be_nil
  end
end
