# find contests from Manny not yet loaded into the database
# retrieve those contests and load them
# use rails runner lib/iac/updateContestDB.rb
require "iac/mannyParse"
require "iac/mannyToDB"
require "net/http"
require "date"

MANNY_HOST = 'donkeykong.highroaddata.com'
MANNY_PORT = 1001

# process one record of the contest list
#tabs (09) delimit fields
# ch is a hash of contest id => last update time
def processListRecord(ch, rcd)
  if !(rcd =~ /ContestList\>/)
    ctst = rcd.split("\t")
    if 10 < ctst.length 
      #puts ctst[0] << ' ' << ctst[2] << ' ' << ctst[9]
      ch[ctst[0].to_i] = ctst[9]
    end
  end
end

#retrieve and process content of Manny contest list
#tabs (09) delimit fields
#CR's (0D) delimit records 
#returns a hash of contest id => last update time
def processContestList
  ch = {}
  tail = ''
  Net::HTTP.start(MANNY_HOST, MANNY_PORT) do |http|
    http.post('/', '<ContestList/>', {'Content-Type' => 'text/xml'}) do |data| 
      data = tail << data
      aRcd = data.split("\r")
      if !aRcd.empty?
        tail = aRcd.last
        aRcd.pop
        aRcd.each { |rcd| processListRecord ch, rcd }
      end
    end
  end
  # tail should be empty because data ends with a record delimiter
  ch
end

def getHaveList
  haveList = {}
  MannySynch.all().each { |rcd| haveList[rcd.manny_number] = rcd.synch_date }
  haveList
end

#find list of database contest id's that are
# missing or out of date with respect to Manny
def findMissingContests(curList)
  haveList = getHaveList
  curList.reject do |id, date|
    false # do not remove == will retrieve
    if haveList.has_key?(id) 
      # date format from Manny looks like: 8/5/2009 9:55:27 PM
      curStamp = DateTime.strptime(date, '%m/%d/%Y %I:%M:%S %p')
      # do not retrieve if manny date precedes database last synch date
      curStamp < haveList[id] 
    end
  end
end

#find list of past Manny database contest id's that no longer have
# any counterpart with respect to the current Manny list
def findSpuriousContests(curList)
  getHaveList.reject { |id, date| curList.include?(id) }
end

#retrieve a contest from Manny, parse it, and add it to the database
# id is Manny identifier for the contest.
def doProcessContest(m2d, id)
  query = "<ContestDetail><ContestID>#{id}</ContestID></ContestDetail>"
  manny = Manny::MannyParse.new
  tail = ''
  Net::HTTP.start(MANNY_HOST, MANNY_PORT) do |http|
    http.post('/', query, {'Content-Type' => 'text/xml'}) do |data| 
      data = tail << data
      aRcd = data.split("\r")
      if !aRcd.empty?
        tail = aRcd.last
        aRcd.pop
        aRcd.each { |rcd| manny.processLine(rcd) }
      end
    end
  end
  m2d.process_contest(manny, true)
end

def processContest(m2d, k)
  puts "Retrieving contest id #{k}"
  begin
    doProcessContest(m2d, k)
  rescue Exception => e
    puts "Problem with contest id #{k} is #{e}"
    puts e.backtrace
  end
end

def removeContest(m2d, k)
  puts "Should remove contest id #{k}"
end

reload = !ARGV.empty? && ARGV[0] == 'reload'
files = reload ? ARGV.drop(1) : ARGV
m2d = IAC::MannyToDB.new
if files.size == 0
  curList = processContestList
  doList = reload ? curList : findMissingContests(curList)
  doList.each_key do |k| 
    processContest(m2d, k)
  end
  findSpuriousContests(curList).each_key do |k|
    removeContest(m2d, k)
  end
else
  files.each do |arg|
    k = arg.to_i
    if (k != 0) then processContest(m2d, k) end
  end
end
