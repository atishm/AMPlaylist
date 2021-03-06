import getopt, string, re, sys, os
from os.path import join, abspath
import xml.etree.ElementTree as ET
import id3image

if len(sys.argv) != 2:
  print "Usage: playlistToText.py [path to collection file directory]"
  exit(1)
else:
  directory = sys.argv[1]
  print "Using directory %s" % directory

# The traktor playlist folder name
FOLDER_NAMES = ["H2", "2014 - midyear"]

def main():
  for subdir, dirs, files in os.walk(directory):
    for file in files:
      filename = abspath(join(subdir, file))
      try:
        filetype = str(filename[-3:]).upper()
        if str(filetype) == str('NML'):
          parseCollection(filename)
    
      except Exception, message:
          print "Problem:", message

trackKeysInDesiredPlaylists = {}
allTracks = {}

def parseCollection(fileName):
#iconv -f UTF-8 -t ISO-8859-15 in.txt > out.txt
  print "Parsing %s \n " % fileName
  try:
    tree = ET.parse(fileName)
    root = tree.getroot()
    
    parseAllTracks(root)
    
    writePath = "%s/playlists.txt" % directory
    writeFile = open(writePath, 'w')

    for folderName in FOLDER_NAMES:
      desiredFolderNode = findDesiredFolderNode(root, folderName)
      for playlist in desiredFolderNode.iter('NODE'):
        nodeType = safeParse(playlist, 'TYPE')
        if (nodeType == "PLAYLIST"):
          parsedPlaylist = parsePlaylist(playlist)
          #print parsedPlaylist
          writeFile.write("\n")
          writeFile.write(parsedPlaylist)

    writeFile.close()

  except Exception, message:
    print "Top level exception: %s %s" % (Exception, message)


def parsePlaylist(nodePlaylist):
  playlistName = safeParse(nodePlaylist, 'NAME')
  returnString = playlistName
  print "parsing playlist: ", playlistName
  for primaryKey in nodePlaylist.iter('PRIMARYKEY'):
    try:
      keyType = safeParse(primaryKey, 'TYPE')
      key = safeParse(primaryKey, 'KEY')
      if(key in allTracks):
        dumpString = allTracks[key][0]
        pathToFile = allTracks[key][1]
        fileName = allTracks[key][2].replace(' ','')
        returnString = "%s\n%s" % (returnString, dumpString)
      
        id3image.getImagePathForMp3(pathToFile, fileName, directory)
      else:
        print "key was found in playlist, but not master collection: ", key
    except Exception, message:
      print "Error parsing playlist key: %s" % (message)
  return returnString

def findDesiredFolderNode(root, desiredFolderName):
  for node in root.iter('NODE'):
    nodeType = safeParse(node, 'TYPE')
    nodeName = safeParse(node, 'NAME')
    if (nodeType == "FOLDER" and nodeName == desiredFolderName):
      return node
  return None

def safeParse(element, attributeName):
  if element is not None:
    attribute = element.get(attributeName)
    if attribute:
      return attribute.encode('utf-8')
  return ""

def parseAllTracks(root):
  try:
    collection = root.find('COLLECTION')
    for entry in collection.findall('ENTRY'):
      #location
      location = entry.find('LOCATION')
      dir = safeParse(location, 'DIR')
      file = safeParse(location, 'FILE')
      fileSpacesRemoved = file.replace(' ','')
      volume = safeParse(location, 'VOLUME')
      primaryKey = "%s%s%s" % (volume, dir, file)
      
      filePathDir = dir.replace(":", '')
      actualPathToFile = "%s%s" % (filePathDir, file)
      
      #print primaryKey
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
      ranking = safeParse(info, 'RANKING')
      if ranking:
        ranking = int(ranking)
      if (ranking == 51):
        ranking = 1
      elif (ranking == 102):
        ranking = 2
      elif (ranking == 153):
        ranking = 3
      elif (ranking == 204):
        ranking = 4
      elif (ranking == 255):
        ranking = 5
      else:
        ranking = 0
      
      
      #tempo
      tempo = entry.find('TEMPO')
      bpm = safeParse(tempo, 'BPM')

      printString = "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s" %  (title, time, artist, bpm, comment, key, fileSpacesRemoved, ranking)
      allTracks[primaryKey] = [printString, actualPathToFile, file]
  except Exception, message:
    print "Error parsing track: %s %s" % (Exception, message)

main()