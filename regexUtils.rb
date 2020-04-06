#!/bin/ruby
require 'csv'


=begin
basic intended usage:
  regexUtils <csv file path>
adv: 
  regexUtils <csv file path> <regex name> <output file name> 
EVERYTHING WILL BE RETURNES AS A CSV WITH " STRING ", '"' will be stripped from input text

flow:
init, load regex file
preProcess, load and prepare data 
process, do the regEx pass
write, output csv

=end
#sample regex explained
VdaRe = %r{
  en las? veredas?      #start with 'en la vereda' with optional 's'
  ([^\.]+               #capture group '()' captures any class '[]' that isn't '^' a dot '\.' (as dot is reserved it must be escaped)
  \.)                   #matches next dot
  }x
  
  
#sample regex dict, also for testing purposes
regexDict = {    
  'en la+s vereda+s' => 'en\slas?\sveredas?\s([^\.]+\.)', #sample regex will match from 'en la/s vereda/s' until next dot
  '-1' => 'en\slas?\sveredas?\s([^\.]+\.)' 
}

#returns matches as array of strings
def matchLine( line, re )
  line.scan( /#{re}/ ).flatten()
end
  
define_method (:loadRegex){
  |reName|
  reName.nil? ? regexDict['-1'] : File.foreach( "./regex.txt" ) {
    |rxf| 
    if (rxf[0] == '#') 
      next 
    end
    if !rxf.index(/^#{reName};\s/).nil?
      return rxf[/^#{reName};\s(.+)/, 1]
    end
  }
  
}

#returns array of arrays  [id, text] , removes invalid (nil) rows
def preProcess( inPath )
  inPath = inPath
  data = CSV.parse(File.read(inPath.to_s), headers:true )
  ret = data['id'].zip data['text']
  ret.reject! { |r| r.nil?||r[0].nil?||r[1].nil? }
end

#processes data, returns [id, [match , match]], receives regex as string
define_method(:applyRx){
  |data , rex |
  data.map! { |x| [x[0] , matchLine( x[1] , rex )] }
}

define_method(:array2csv){
  |data|
  CSV.generate_line( data.flatten  )
}

define_method(:writeMatches){
  |outPath, data|
  outF = File.open( outPath , 'w' )
  data.each {
    |rdata|
    outF.write( array2csv( rdata ) )
  }
  outF.close

}

help = 
  "\nuse: regexUtils <csv file path> <regex name> <output file name>\n
  output path = ./out/<file name>?.csv
  regex name defaults to '-1', check regex.txt for info
  <csv file path>: file to process
  "
#regexUtils <csv file path> <regex name> <output file name> 
define_method (:main){
  if ARGV[0].nil?
    return  puts help
  end
  outPath = ARGV[2].nil? ? "./#{ARGV[0][0..-5]}#{ARGV[1]}matches.csv" : "./#{ARGV[2]}"
  rex = loadRegex( ARGV[1] )
  data = preProcess( ARGV[0] )
  puts "[in]: #{ARGV[0]} ====>> [out]: #{outPath}"
  writeMatches(  outPath , applyRx( data , rex ) )
}

main()