# frozen_string_literal: true

require 'tsplib'

class Concorde

  def initialize(tsp)
    @tsp = tsp
  end

  def run

    # Create temporary directory.

    Dir.mktmpdir do |dir|

      # Create 'tsplib' directory in temporary directory.

      tspdir = "#{dir}/tsplib"
      Dir.mkdir(tspdir)

      # Write TSP file into 'tsplib' directory.

      File.open("#{tspdir}/problem.tsp", 'w') do |f|
        f.puts(@tsp.to_s)
      end

      docker_cmd = "docker run --rm -t -v #{tspdir}:/usr/local/opt/concorde/ alehkot/concorde-tsp:1.0 problem.tsp" +
                   " > /dev/null 2>&1"
      system(docker_cmd)

      sol = File.open("#{tspdir}/problem.sol") do |f|
        f.read.split.drop(1).map { |s| s.to_i }
      end

      sol

    end
  end

end
