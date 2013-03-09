# encoding: utf-8
module BSON

  # Represents a timestamp type, which is predominately used for sharding.
  #
  # @see http://bsonspec.org/#/specification
  #
  # @since 2.0.0
  class Timestamp
    include JSON

    # A timestamp is type 0x11 in the BSON spec.
    #
    # @since 2.0.0
    BSON_TYPE = 17.chr.force_encoding(BINARY).freeze

    # Constant for the timestamp pack directive.
    #
    # @since 2.0.0
    TIMESTAMP_PACK = "l2".freeze

    # @!attribute seconds
    #   @return [ Integer ] The number of seconds.
    #   @since 2.0.0
    #
    # @!attribute increment
    #   @return [ Integer ] The incrementing value.
    #   @since 2.0.0
    #
    attr_reader :seconds, :increment

    # Determine if this timestamp is equal to another object.
    #
    # @example Check the timestamp equality.
    #   timestamp == other
    #
    # @param [ Object ] other The object to compare against.
    #
    # @return [ true, false ] If the objects are equal.
    #
    # @since 2.0.0
    def ==(other)
      return false unless other.is_a?(Timestamp)
      seconds == other.seconds && increment == other.increment
    end

    # Get the timestamp as JSON hash data.
    #
    # @example Get the timestamp as a JSON hash.
    #   timestamp.as_json
    #
    # @return [ Hash ] The timestamp as a JSON hash.
    #
    # @since 2.0.0
    def as_json(*args)
      { "t" => seconds, "i" => increment }
    end

    # Instantiate the new timestamp.
    #
    # @example Instantiate the timestamp.
    #   BSON::Timestamp.new(5, 30)
    #
    # @param [ Integer ] seconds The number of seconds.
    # @param [ Integer ] increment The increment value.
    #
    # @since 2.0.0
    def initialize(seconds, increment)
      @seconds, @increment = seconds, increment
    end

    # Get the timestamp as its encoded raw BSON bytes.
    #
    # @example Get the timestamp as BSON.
    #   timestamp.to_bson
    #
    # @return [ String ] The raw BSON bytes.
    #
    # @see http://bsonspec.org/#/specification
    #
    # @since 2.0.0
    def to_bson
      [ increment, seconds ].pack(TIMESTAMP_PACK)
    end

    # Deserialize timestamp from BSON.
    #
    # @param [ BSON ] bson The bson representing a timestamp.
    #
    # @return [ Timestamp ] The decoded timestamp.
    #
    # @see http://bsonspec.org/#/specification
    #
    # @since 2.0.0
    def self.from_bson(bson)
      new(*bson.read(8).unpack(Int32::PACK * 2).reverse)
    end

    # Register this type when the module is loaded.
    #
    # @since 2.0.0
    Registry.register(BSON_TYPE, self)
  end
end
