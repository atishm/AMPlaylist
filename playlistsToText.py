import getopt, string, re, sys, os
from os.path import join, abspath
import xml.etree.ElementTree as ET

if len(sys.argv) != 2:
  print "Usage: playlistToText.py [path to nmls]"
  exit(1)
else:
  directory = sys.argv[1]
  print "Using directory %s" % directory


def main():
  for subdir, dirs, files in os.walk(directory):
    for file in files:
      filename = abspath(join(subdir, file))
      try:
        filetype = str(filename[-3:]).upper()
        if str(filetype) == str('NML'):
          printPlaylist(filename)
    
      except Exception, message:
          print "Problem:", message

def printPlaylist(fileName):
#iconv -f UTF-8 -t ISO-8859-15 in.txt > out.txt
  print "parsing ", fileName
  try:
    tree = ET.parse(fileName)
    root = tree.getroot()
  
    collection = tree.find('COLLECTION')
    for entry in collection.findall('ENTRY'):
      title = safeParse(entry, 'TITLE')
      artist = safeParse(entry, 'ARTIST')
      

      #info
      info = entry.find('INFO')
      comment = safeParse(info, 'COMMENT')
      playtime = int(safeParse(info, 'PLAYTIME'))
      minutes = playtime / 60
      seconds = playtime & 60
      if (seconds < 60):
        seconds = "0%s" % seconds
      time = "%s:%s" % (minutes, seconds)
      
      

      print "%s \t %s \t %s" %  (title, time, artist)


  except Exception, message:
    print "%s %s" % (Exception, message)

def safeParse(element, attributeName):
  return element.get(attributeName).encode('utf-8')

main()