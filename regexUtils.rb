#!/bin/ruby
require 'csv'
require 'json'

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
  'vereda' => 'en.{1,25}la\svereda\s(.{1,25})',
  'municipio' => 'en.{1,70}\smunicipio\s(.{1,25})',
  'dpto' => 'depatamento\s(.{1,25})',

  'en la+s vereda+s' => 'en\slas?\sveredas?\s([^\.]+\.)', #sample regex will match from 'en la/s vereda/s' until next dot
  '-1' => 'en\slas?\sveredas?\s([^\.]+\.)' ,
  '-2' => '.*'
}

#dah
regexDictLine = {
  'vereda' => /en.{1,25}la\svereda\s(.{1,25})/i,
  'municipio' => /en.{1,70}\smunicipio\s(.{1,25})/i,
  'dpto' => /depatamento\s(.{1,25})/i
}

#returns matches as array of strings
def matchLine( line, re )
  line.scan( /#{re}/i ).flatten()
end
  
define_method (:loadRegex){
  |reName|
  reName.nil? ? regexDict['-2'] : File.foreach( "./regex.txt" ) {
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
  data = CSV.parse(File.read(inPath.to_s), headers:true , encoding: 'UTF-8')
  ret = data['id'].zip data['text']
  ret.reject! { |r| r.nil?||r[0].nil?||r[1].nil? }
end

def preProcessBB( inPath )
  inPath = inPath
  data = CSV.parse(File.read(inPath.to_s), headers:true , encoding: 'UTF-8')
  ret = data[data.headers[0]].zip data[data.headers[1]], data[data.headers[2]], data[data.headers[3]], data[data.headers[4]], data[data.headers[5]], data[data.headers[6]], data[data.headers[7]], data[data.headers[8]], data[data.headers[9]], data[data.headers[10]], data[data.headers[11]], data[data.headers[12]]
  ret.reject! { |r| r.nil?||r[0].nil?}
  return data,ret
end

#processes data, returns [id, [match , match]], receives regex as string
define_method(:applyRx){
  |data , rex |
  data.map! { |x| [x[0] , matchLine( x[1] , rex )] }
}

define_method(:applyRx2){
  |data , rex |
  data.map! { |x|  [matchLine( x , rex )] }
}

define_method(:array2csv){
  |data|
  CSV.generate_line( data.flatten  )
}

define_method(:writeMatches){
  |outPath, data, heads|
  CSV.open( outPath , 'w' , 
    :write_headers => true, 
    :headers => heads ) do |csvF|
      data.each {
        |rdata|
        csvF << rdata 
      }
  end

}

help = 
  "\nuse: regexUtils <csv file path> <output file name?> <regex name?>\n
  
  <csv file path>: file to process
  output path = ./out/<file name>?.csv
  if no regex provided to load defaults to black box functionality (csv + vereda,municipio, departamento )
  
  "

define_method (:main){
  if ARGV[0].nil?
    return  puts help
  end
  outPath = ARGV[1].nil? ? "./#{ARGV[0][0..-5]}#{ARGV[1]}matches.csv" : "./#{ARGV[1]}"
  if(ARGV[2].nil?)
    BBres,heads = blackBoxFun(ARGV[0], regexDict)
    puts "[in]: #{ARGV[0]} ====>> [out]: #{outPath}"
    writeMatches(  outPath , BBres , heads)
  else
    rex = loadRegex( ARGV[2] )
    data = preProcess( ARGV[0] )
    puts "[in]: #{ARGV[0]} ====>> [out]: #{outPath}"
    writeMatches(  outPath , applyRx( data , rex ) )
  end
  
}

#what do i want'??
#generate output as input w extra cols
#receives a CSV, applies basic RE and returns first 13 colsa + matches as CSV
def blackBoxFun(inPath, regexDict)
 data,save = preProcessBB(inPath)
 veredas = applyRx2(data['text'].reject!{|x| x.nil?}, regexDict['vereda'] )
 municipios = applyRx2(data['text'].reject!{|x| x.nil?}, regexDict['municipio'] )
 dptos = applyRx2(data['text'].reject!{|x| x.nil?}, regexDict['dpto'] )
 results = []
 (save.zip veredas,municipios,dptos).each{
   |x| 
   results.push(
      x[0]+ 
      (x[1][0].empty? ? [""]: [x[1][0][0]]) + #vereda
      (x[2][0].empty? ? [""]: [x[2][0][0]]) + #municipio
      (x[3][0].empty? ? [""]: [x[3][0][0]]) ) #dpto
     
    }
  return results , (data.headers[0..12]+['vereda','municipio','departamento'])
end



#func that returns json w matches, from map
define_method(:blackBoxLine){
  |sampleStr, regexes = regexDictLine|
  results = {}
  regexes.each{ |x,y|
    m = y.match(sampleStr)
    results.store(x, (m.nil? ? "" : m[1] ) )
  }
  return results

}
define_method(:blackBoxLineJson){
  |sampleStr, regexes = regexDictLine|
  return blackBoxLine(sampleStr, regexes).to_json
}


main()