module Dynamican
  def self.configuration
    @configuration ||= Configuration.new(configuration_hash)
  end

  def self.configuration_hash
    @configuration_hash ||= HashWithIndifferentAccess.new(YAML.load_file('config/dynamican.yml'))
  end

  class Configuration
    attr_accessor :associations

    def initialize(configuration_hash)
      @associations = configuration_hash[:associations]
    end
  end
end
