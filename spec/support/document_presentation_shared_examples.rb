shared_examples_for "a document presentation" do
  it "has a reference to the original document" do
    expect(presentation).to respond_to :document
    expect(presentation.document).to be document
  end
end
