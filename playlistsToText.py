import getopt, string, re, sys, os
from os.path import join, abspath
import xml.etree.ElementTree as ET

if len(sys.argv) != 2:
  print "Usage: playlistToText.py [path to nmls]"
  exit(1)
else:
  directory = sys.argv[1]
  print "Using directory %s" % directory

# The traktor playlist folder name
FOLDER_NAME = "2014 BM"

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
    
    desiredFolderNode = findDesiredFolderNode(root)
    for playlist in desiredFolderNode.iter('NODE'):
      nodeType = safeParse(playlist, 'TYPE')
      if (nodeType == "PLAYLIST"):
        parsePlaylist(playlist)
  
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
      key = safeParse(info, 'KEY')
      
      #tempo
      tempo = entry.find('TEMPO')
      bpm = safeParse(tempo, 'BPM')
    
#print "%s \t %s \t %s \t %s \t %s \t %s" %  (title, time, artist, bpm, comment, key)


  except Exception, message:
    print "%s %s" % (Exception, message)


def parsePlaylist(nodePlaylist):
  playlistName = safeParse(nodePlaylist, 'NAME')
  for primaryKey in nodePlaylist.iter('PRIMARYKEY'):
    keyTpe = safeParse(primaryKey, 'TYPE')
    key = safeParse(primaryKey, 'KEY')
    print key


def findDesiredFolderNode(root):
  for node in root.iter('NODE'):
    nodeType = safeParse(node, 'TYPE')
    nodeName = safeParse(node, 'NAME')
    if (nodeType == "FOLDER" and nodeName == "2014 BM"):
      return node
  return None

def safeParse(element, attributeName):
  attribute = element.get(attributeName)
  if attribute:
    return attribute.encode('utf-8')
  else:
    return ""

main()