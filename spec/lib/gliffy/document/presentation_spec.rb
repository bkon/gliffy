require 'spec_helper'

describe Gliffy::Document::Presentation do
  let(:document) { double(Gliffy::Document) }
  let(:presentation) { Gliffy::Document::Presentation.new(document) }

  it_should_behave_like "a document presentation" 
end
