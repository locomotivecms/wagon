RSpec::Matchers.define :have_key_with_value do |key, expected|
  match do |actual|
    actual[key] == expected
  end
end