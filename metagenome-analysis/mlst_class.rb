
class Mlst
  attr_accessor :strain, :concatname, :genenames, :sequences

  def initialize(s,c,g)
    @strain = s
    @concatname = c
    @genenames = g
    @sequences = Array.new
  end

  def addgene(name,sequence)
    @genenames.each_index do |i|
      if @genenames[i] == name
        @sequences[i] = sequence
      end
    end
  end
  
  def summary(format="cat")
    if format == "cat"
      ">#{@strain}_#{@genenames}\n#{@sequences.join("")}\n"
#    else
#      "#{@strain}_#{@genename1}\n#{@gene1}\n#{@strain}_#{@genename2}\n#{@gene2}\n
#      #{@strain}_#{@genename3}\n#{@gene3}\n#{@strain}_#{@genename4}\n#{@gene4}\n
#      #{@strain}_#{@genename5}\n#{@gene5}"
    end
  end

  def to_s
    summary
  end

end

