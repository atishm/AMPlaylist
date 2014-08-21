import mutagen
from mutagen.id3 import ID3
from mutagen import File
import os
import subprocess

def getImagePathForMp3(pathToMp3, uniqueIdentifier, directory):
  try:
    imagesDirectory = "%s/images/" % (directory)
    if not os.path.exists(imagesDirectory):
      os.makedirs(imagesDirectory)
  
    command = "eyeD3 --write-images \"%s\" \"%s\"" % (imagesDirectory, pathToMp3)
    os.system(command)

    front_cover_path = "%s/FRONT_COVER.jpeg" % imagesDirectory
    outputImageName = "%s/%s.jpeg" % (imagesDirectory, uniqueIdentifier)
    mv_command = "mv \"%s\" \"%s\"" % (front_cover_path, outputImageName)
    os.system(mv_command)
        #with open(outputImageName, 'wb') as output:
        #output.write(artwork)
        #output.close()

  except Exception, message:
    print "Problem reading image:", Exception, message


def getImagePathForMp3_old(pathToMp3, uniqueIdentifier,directory):
  try:
    file = File(pathToMp3) # mutagen can automatically detect format and type of tags
    if file is not None and 'APIC:' in file.tags:
      tags = file.tags
      artwork = tags['APIC:']
      print artwork.type
      '''
      imagesDirectory = "%s/images/" % (directory)
      if not os.path.exists(imagesDirectory):
        os.makedirs(imagesDirectory)
  
      outputImageName = "%s/%s.jpg" % (imagesDirectory, uniqueIdentifier)
      with open(outputImageName, 'wb') as output:
        output.write(artwork)
        output.close()
      '''
  except Exception, message:
    print "Problem reading image:", Exception, message
