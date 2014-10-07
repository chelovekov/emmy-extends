module EmmyExtends
  module CoreExt
    refine Hash do
      def transform_values
        return enum_for(:transform_values) unless block_given?
        result = self.class.new
        each do |key, value|
          result[key] = yield(value)
        end
        result
      end

      def stringify_keys
        transform_keys{ |key| key.to_s }
      end

      def symbolize_keys
        transform_keys{ |key| key.to_sym rescue key }
      end
      alias_method :to_options,  :symbolize_keys
    end
  end
end
