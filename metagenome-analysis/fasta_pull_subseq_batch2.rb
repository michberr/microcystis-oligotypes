#/usr/bin/ruby -w

require '/home2/vdenef/software/scripts/ruby/mybioruby/lib/nubio.rb'
require '/home2/vdenef/software/scripts/ruby/mlst_class.rb'

unless ARGV.length == 4
  puts "This script produces subsequences from a multifasta file based on blast output sequence positions.
   Arguments are (1) contig multifasta file (2) blast output (outfmt 6 of balst+) (3) outputfile name (4) %id cutoff
   The script assumes you ran blast pulling only the top hit, though can include (gapped) multiple hits to the same subject (contig).
   To avoid secondary hits on same scaffold, a % identity cutoff is added"
  exit(1)
end

puts "Loading contigs into hash"
contigs = Hash.new
NuBio::Parser::Fasta.new(ARGV[0]).each do |f|
  contigs[f.header] = f.sequence
end
  
puts "Loading coordinates for blast hits"
coord = Hash.new
File.open(ARGV[1]) do |file|
  file.each do |line|
    line.chomp!
    bl = BlastHit.new(line)
    if coord.key?("#{bl.query}")
      if bl.sbjct = coord["#{bl.query}"].sbjct
        if bl.percent.to_f > ARGV[3].to_f
          if bl.s_start.to_i < bl.s_end.to_i
            if bl.s_start.to_i < coord["#{bl.query}"].s_start.to_i
              coord["#{bl.query}"].s_start = bl.s_start
            end
            if bl.s_end.to_i > coord["#{bl.query}"].s_end.to_i
              coord["#{bl.query}"].s_end = bl.s_end
            end
          else
            if bl.s_start.to_i > coord["#{bl.query}"].s_start.to_i
              coord["#{bl.query}"].s_start = bl.s_start
            end
            if bl.s_end.to_i < coord["#{bl.query}"].s_end.to_i
              coord["#{bl.query}"].s_end = bl.s_end
            end
          end
        end
      end
    else
      if bl.percent.to_f > ARGV[3].to_f
        coord["#{bl.query}"] = bl
      end
    end
  end
end


outfile = File.new(ARGV[2],"w")
puts "writing genes for target organism to #{ARGV[2]}"

coord.each_key do |key|
  if coord[key].s_start.to_i < coord[key].s_end.to_i
    start = coord[key].s_start
    stop = coord[key].s_end
  else
    start = coord[key].s_end
    stop = coord[key].s_start
  end    
  temp = contigs["#{coord[key].sbjct}"].split("")
  outseq = Array.new
  temp.each_index do |i|
    if i > start.to_i - 2 and i < stop.to_i
      outseq.push temp[i]
    end
  end
  options = {
    :type  => "dna",
    :value => outseq.join(""),
    :name => "#{coord[key].query}:#{ARGV[2]}_#{coord[key].sbjct}_#{start}-#{stop}"
  }
  seq = NuBio::Sequence::Fasta.new(options)
  if coord[key].s_start.to_i > coord[key].s_end.to_i
    puts "reverse complementing #{coord[key].query} since #{coord[key].s_start.to_i} > #{coord[key].s_end.to_i}"
    seq.value = seq.reverse_complement!
  end
  outfile.puts seq
end
outfile.close

