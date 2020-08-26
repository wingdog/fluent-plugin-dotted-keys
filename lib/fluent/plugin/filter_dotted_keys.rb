module Fluent
  class DottedKeysFilter < Filter

    Plugin.register_filter('dotted_keys', self)

    def configure(conf)
      super
      # do the usual configuration here
    end

    def start
      super
      # This is the first method to be called when it starts running
      # Use it to allocate resources, etc.
    end

    def shutdown
      super
      # This method is called when Fluentd is shutting down.
      # Use it to free up resources, etc.
    end


    def transform_v0(record)
      new_hash = {}

      record.each do |key, value|
        h = new_hash

        parts = key.to_s.split('.')
        while parts.length > 0
          new_key = parts[0]
          rest = parts[1..-1]

          if not h.instance_of? Hash
            raise ArgumentError, "Trying to set key #{new_key} to value #{value} on a non hash #{h} with #{record}, #{new_hash}\n"
          end

          if rest.length == 0
            if h[new_key].instance_of? Hash
              raise ArgumentError, "Replacing a hash with a scalar. key #{new_key}, value #{value}, current value #{h[new_key]}\n"
            end

            h.store(new_key, value)
            break
          end

          if h[new_key].nil?
            h[new_key] = {}
          end

          h = h[new_key]
          parts = rest
        end
      end

      new_hash
    end

    #
    # Solutions v1 & v2 taken from stack overflow
    # http://stackoverflow.com/questions/4364891/how-to-transform-dot-notation-string-keys-in-a-hash-into-a-nested-hash
    #
    # Tweaked the variable names so they're consistent across both versions
    #
    def transform_v1(record)
      new_hash = {}
      record.each do |key, value|
        new_key, sub_key = key.to_s.split('.')
        #new_key = new_key.to_sym
        unless sub_key.nil?
          #sub_key = sub_key.to_sym
          new_hash[new_key] = {} if new_hash[new_key].nil?
          new_hash[new_key].merge!({sub_key => value})
        else
          new_hash.store(key, value)
        end
      end
      new_hash
    end

    def transform_v2(record)
      new_hash = Hash.new { |hash, key| hash[key] = {} }

      record.each do |key, value|
        if key.respond_to? :split
          key.split('.').each_slice(2) do |new_key, sub_key|
            # new_key = new_key.to_sym
            unless sub_key.nil?
              # sub_key = sub_key.to_sym
              new_hash[new_key].store(sub_key, value)
            else
              new_hash.store(new_key, value)
            end
          end
          next
        end
        new_hash[key] = value
      end

      return new_hash
    end


    def filter(tag, time, record)
      begin
        return transform_v0(record)
      rescue ArgumentError => e
        log.warn "Could not dotted_keys transform the record. #{e.message}"
      end
      return record
    end

  end
end
