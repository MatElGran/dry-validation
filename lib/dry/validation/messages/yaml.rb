require 'yaml'
require 'pathname'

require 'dry/validation/messages/abstract'

module Dry
  module Validation
    class Messages::YAML < Messages::Abstract
      DEFAULT_PATH = Pathname(__dir__).join('../../../../config/errors.yml').freeze

      attr_reader :data

      def self.load(path = DEFAULT_PATH)
        new(load_file(path))
      end

      def self.load_file(path)
        flat_hash(YAML.load_file(path))
      end

      def self.flat_hash(h, f = [config.root], g = {})
        return g.update(f.join('.'.freeze) => h) unless h.is_a? Hash
        h.each { |k, r| flat_hash(r, f + [k], g) }
        g
      end

      def initialize(data)
        @data = data
      end

      def get(key)
        data[key]
      end

      def key?(key)
        data.key?(key)
      end

      def merge(overrides)
        if overrides.is_a?(Hash)
          self.class.new(data.merge(self.class.flat_hash(overrides)))
        else
          self.class.new(data.merge(Messages::YAML.load_file(overrides)))
        end
      end
    end
  end
end
