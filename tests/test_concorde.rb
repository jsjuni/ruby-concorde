# frozen_string_literal: true


require 'minitest/autorun'
require 'tsplib'
require 'concorde'

class TestConcorde < Minitest::Test

  def test_concorde

    tsp = TSPLIB::TSP.new('gr17', '17-city problem (Groetschel)', 17)
    0.upto(16) do |i|
      0.upto(i) do |j|
        tsp.weight[i][j] = TSP_WEIGHTS[i][j]
      end
    end

    concorde = Concorde.new(tsp)
    sol = concorde.run
    assert_equal(sol, [0, 15, 11, 8, 4, 1, 9, 10, 2, 14, 13, 16, 5, 7, 6, 12, 3])

  end

end
