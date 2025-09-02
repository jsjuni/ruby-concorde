# frozen_string_literal: true

require 'open3'
require 'tsplib'
require 'tmpdir'

class Concorde

  def initialize(tsp, options = nil)
    @tsp = tsp
    @options = options
    @tour = nil
    @cost = nil
    @lower_bound = nil
    @upper_bound = nil
  end

  attr_reader :tour, :cost, :lower_bound, :upper_bound

  def optimize(tolerance = nil, &block)

    # Create temporary directory.

    Dir.mktmpdir do |dir|

      # Create 'tsplib' directory in temporary directory.

      Dir.chdir(dir) do

        File.open("problem.tsp", 'w') do |f|
          f.puts(@tsp.to_s)
        end

        concorde_cmd = "concorde -o problem.sol #{@options} problem.tsp 2> /dev/null"
        Open3.popen2e(concorde_cmd) do |stdin, stdout_err, wait_thr|

          stdout_err.each do |line|

            yield line if block_given?

            case
            when m = line.match(/Optimal Solution: ([[:digit:]]+(\.[[:digit:]]*)?)/)
              @cost = m[1].to_i
            when m = line.match(/TOUR FOUND - upperbound is ([[:digit:]]+(\.[[:digit:]]*)?)/)
              @upper_bound = m[1].to_f
            when m = line.match(/LOWER BOUND: ([[:digit:]]+(\.[[:digit:]]*)?)/)
              if @upper_bound && tolerance
                @cost = @upper_bound
                @lower_bound = m[1].to_f
                error = (@upper_bound - @lower_bound) / @lower_bound
                yield "error #{error}" if block_given?
                if error < tolerance
                  Process.kill('TERM', wait_thr.pid)
                  begin
                    Process.waitpid(wait_thr.pid)
                  rescue Errno::ECHILD, Errno::ESRCH
                    # Ignored
                  end
                  break
                end
              end
            else {}
            end
          end

          wait_thr.join
        end

        @tour = File.open("problem.sol") do |f|
          f.read.split.drop(1).map { |s| s.to_i }
        end

      end
    end

  end

end
