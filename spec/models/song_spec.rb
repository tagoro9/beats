require 'spec_helper'

describe "Song Model" do
  let(:song) { Song.new }
  it 'can be created' do
    song.should_not be_nil
  end
end
