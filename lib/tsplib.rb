# frozen_string_literal: true

module TSPLIB

  EOF = 'EOF'

  class Problem

    attr_reader :name, :comment, :dimension, :weight

    def initialize(name, comment, dimension)
      @name = name
      @comment = comment
      @dimension = dimension
      @edge_weight_type = 'EXPLICIT'
      @weight = Array.new(@dimension) { Array.new(@dimension) }
      @edge_weight_format = 'FULL_MATRIX'
    end

    def to_s
      [
        "NAME: #{@name}",
        "TYPE: #{@type}",
        "COMMENT: #{@comment}",
        "DIMENSION: #{@dimension}",
        "EDGE_WEIGHT_TYPE: #{@edge_weight_type}",
        "EDGE_WEIGHT_FORMAT: #{@edge_weight_format}",
        'EDGE_WEIGHT_SECTION',
        ''
      ].join("\n")
    end

 end

  class TSP < Problem

    def initialize(name, comment, dimension)
      super(name, comment, dimension)
      @type = 'TSP'
      @edge_weight_format = 'LOWER_DIAG_ROW'
    end

    def to_s
      super + 0.upto(@dimension - 1).inject([]) do | a,i|
        a << @weight[i][0..i].map { |e| "%5d" % e }.join('')
        a
      end.join("\n") + EOF
    end

  end

  class ATSP < Problem

    def initialize(name, comment, dimension)
      super(name, comment, dimension)
      @type = 'ATSP'
    end

    def to_s
      super + 0.upto(@dimension - 1).inject([]) do |a, i|
        a << @weight[i].map { |e| "%5d" % e }.join('')
        a
      end.join("\n") + EOF
    end

  end

end
