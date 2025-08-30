# frozen_string_literal: true

require 'open3'
require 'tsplib'
require 'tmpdir'

class Concorde

  def initialize(tsp)
    @tsp = tsp
    @tour = nil
    @cost = nil
  end

  attr_reader :tour, :cost

  def optimize(&block)

    # Create temporary directory.

    Dir.mktmpdir do |dir|

      # Create 'tsplib' directory in temporary directory.

      Dir.chdir(dir) do

       File.open("problem.tsp", 'w') do |f|
          f.puts(@tsp.to_s)
        end

        concorde_cmd = "concorde -o problem.sol problem.tsp 2> /dev/null"
        Open3.popen2e(concorde_cmd) do |stdin, stdout_err, wait_thr|

          stdout_err.each do |line|
            if (m = line.match(/Optimal Solution:\s+([[:digit:]]+)(\.[[:digit:]]+)?/))
              @cost = m[1].to_i
            end
            yield line if block_given?
          end

          wait_thr.value

        end

       @tour = File.open("problem.sol") do |f|
          f.read.split.drop(1).map { |s| s.to_i }
        end

      end
    end
  end

end
