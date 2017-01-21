module ModelSpecHelpers
  def expect_field_has_error(model, field)
    expect(model.errors[field].length).to be(1)
  end
end
