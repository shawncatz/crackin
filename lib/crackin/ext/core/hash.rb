class Hash
  def deep_transform_keys(&block)
    result = {}
    each do |key, value|
      result[yield(key)] = value.is_a?(Hash) ? value.deep_transform_keys(&block) : value
    end
    result
  end unless Hash.respond_to?(:deep_transform_keys)

  def deep_stringify_keys
    deep_transform_keys{ |key| key.to_s }
  end unless Hash.respond_to?(:deep_stringify_keys)

  def deep_symbolize_keys
    deep_transform_keys{ |key| key.to_sym }
  end unless Hash.respond_to?(:deep_symbolize_keys)
end
