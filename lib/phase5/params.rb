require 'uri'

module Phase5
  class Params
    # use your initialize to merge params from
    # 1. query string
    # 2. post body
    # 3. route params
    def initialize(req, route_params = {})
      @params = route_params
      if req.query_string
        @params.merge!parse_www_encoded_form(req.query_string)
      end
      if req.body
        @params.merge!(parse_www_encoded_form(req.body))
      end
    end

    def [](key)
      @params[key.to_s]
    end

    def to_s
      @params.to_json.to_s
    end

    class AttributeNotFoundError < ArgumentError; end;

    private
    # this should return deeply nested hash
    # argument format
    # user[address][street]=main&user[address][zip]=89436
    # should return
    # { "user" => { "address" => { "street" => "main", "zip" => "89436" } } }
    def parse_www_encoded_form(www_encoded_form)
      results = { }
      parsed_hash = URI.decode_www_form(www_encoded_form)
      parsed_hash.each do |key, value|
        current_hash = results
        key_array = parse_key(key)
        key_array.each_with_index do |key, i|
          if i == key_array.length - 1
            current_hash[key] = value
          else
            current_hash[key] ||= {}
            current_hash = current_hash[key]
          end
        end
      end
      results
    end

    # this should return an array
    # user[address][street] should return ['user', 'address', 'street']
    def parse_key(key)
      key.split(/\]\[|\[|\]/).map { |x| x.to_s }
    end
  end
end
