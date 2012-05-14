module Wukong
  module Widget

    class Transform < Hanuman::Stage
      # override this in your subclass
      def process(record)
      end

      # passes a record on down the line
      def emit(record)
        output.process(record)
      end

      def report
        self.attributes
      end
    end

    class Identity < Transform
      # accepts records, emits as-is
      def process(*args)
        emit(*args)
      end
    end

    class Null < Transform
      # accepts records, emits none
      def process(*)
        # ze goggles... zey do nussing!
      end
    end

    #
    # Foreach calls a block on every record, and depends on the block to call
    # emit. You can emit one record, many records, or no records, and with any
    # contents. If you'll always emit exactly one record out per record in,
    # you may prefer Wukong::Widget::Map.
    #
    # @example regenerate a wordbag with counts matching the original
    #   foreach{|rec| rec.count.times{ emit(rec.word) } }
    #
    # @see Project
    # @see Map
    class Foreach < Transform
      # @param [Proc] proc used for body of process method
      # @yield ... or supply it as a &block arg.
      def initialize(prc=nil, &block)
        prc ||= block or raise "Please supply a proc or a block to #{self.class}.new"
        define_singleton_method(:process, prc)
      end
    end

    #
    # Evaluates the block and emits the result if non-nil
    #
    # @example turn a record into a tuple
    #   map{|rec| rec.attributes.values }
    #
    # @example pass along first matching term, drop on the floor otherwise
    #   map{|str| str[/\b(love|hate|happy|sad)\b/] }
    #
    class Map < Transform
      attr_reader :blk

      # @param [Proc] proc to delegate for call
      # @yield if proc is omitted, block must be supplied
      def initialize(blk=nil, &block)
        @blk = blk || block or raise "Please supply a proc or a block to #{self.class}.new"
      end

      def process(*args)
        result = blk.call(*args)
        emit result unless result.nil?
      end
    end

    #
    # Flatten emits each item in an enumerable as its own record
    #
    # @example turn a document into all its words
    #   input > map{|line| line.split(/\W+/) } > flatten > output
    class Flatten < Transform
      def process(iter)
        iter.each{|*args| emit(*args) }
      end
    end

  end
end
