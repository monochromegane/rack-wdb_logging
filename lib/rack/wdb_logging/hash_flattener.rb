module Rack
  class WdbLogging::HashFlattener
    attr_accessor :prefix

    def initialize(prefix)
      @prefix = array_wrap(prefix)
    end

    def flatten(hash)
      flatten_hash(hash, prefix)
    end

    private

    def flatten_hash(hash, prefix)
      result = {}
      if hash.kind_of?(Array)
        hash.each_with_index do |val, index|
          result.merge!(flatten_hash(val, prefix + [index.to_s]))
        end
      elsif hash.kind_of?(Hash)
        hash.each do |key, val|
          result.merge!(flatten_hash(val, prefix + [key.to_s]))
        end
      else
        return {prefix.join("_").to_sym => hash.to_s}
      end
      result
    end

    private

    def array_wrap(object)
      if object.nil?
        []
      elsif object.respond_to?(:to_ary)
        object.to_ary || [object]
      else
        [object]
      end
    end
  end
end
