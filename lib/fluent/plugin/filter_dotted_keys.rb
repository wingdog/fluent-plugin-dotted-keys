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


    def transform_v0(tag, time, record)
      new_hash = {}

      # print "\n*****Original Record:\n#{record}\n\n"

      record.each do |key, value|
        # print "============ #{key} / #{value} ================\n"
        h = new_hash
        # print "current new_hash is: #{new_hash}\n"
        # print "current hash is: #{h}\n"

        parts = key.to_s.split('.')
        while parts.length > 0
          new_key = parts[0]
          rest = parts[1..-1]
          # print "----\n"
          # print "current new_key: #{new_key}, rest: #{rest}\n"
          # print "current rest length is now: #{rest.length}\n"
          if rest.length > 0
            # print "trying to set key #{new_key} if nil\n"
            h[new_key] = {} if h[new_key].nil?
          else
            # print "trying to set value for #{new_key}\n"
            if not h[new_key].nil?
              # print "raising an error\n"
              raise ArgumentError, "Hash key #{new_key} is already set to #{h[new_key]}", caller
            end
            # print "trying to do a store of key #{new_key} and value #{value}\n"
            h.store(new_key, value)
          end

          h = h[new_key]
          # print "current hash is now: #{h}\n"
          parts = rest
          # print "current parts is now: #{parts}\n"
          # print "current parts length is now: #{parts.length}\n"
          # print "current new_hash is: #{new_hash}\n"
        end

        # print "Done with while loop\n"
      end

      # print "========= final hash ========\n"
      # print new_hash
      # print "\n=============================\n"
      new_hash
    end

    #
    # Solutions v1 & v2 taken from stack overflow
    # http://stackoverflow.com/questions/4364891/how-to-transform-dot-notation-string-keys-in-a-hash-into-a-nested-hash
    #
    # Tweaked the variable names so they're consistent across both versions
    #
    def transform_v1(tag, time, record)
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

    def transform_v2(tag, time, record)
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

      new_hash
    end

    def filter(tag, time, record)
      # This method implements the filtering logic for individual filters
      # It is internal to this class and called by filter_stream unless
      # the user overrides filter_stream.
      #
      # Since our example is a pass-thru filter, it does nothing and just
      # returns the record as-is.
      # If it returns nil, that record is ignored.
      transform_v0(tag, time, record)
    end

    # This is the filter_stream implmentation in the superclass.  It
    # can be a starting point if you are interested in overriding the
    # filter_stream method

    # def filter_stream(tag, es)
    #   # super
    #   new_es = MultiEventStream.new
    #   es.each { |time, record|
    #     begin
    #       filtered_record = filter(tag, time, record)
    #       new_es.add(time, filtered_record) if filtered_record
    #     rescue => e
    #       router.emit_error_event(tag, time, record, e)
    #     end
    #   }
    #   new_es
    # end
  end
end
