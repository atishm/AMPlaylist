import mutagen
from mutagen.id3 import ID3
from mutagen import File
import os

def getImagePathForMp3(pathToMp3, uniqueIdentifier,directory):
  try:
    file = File(pathToMp3) # mutagen can automatically detect format and type of tags
    if file is not None and 'APIC:' in file.tags:
      artwork = file.tags['APIC:'].data
  
      imagesDirectory = "%s/images/" % (directory)
      if not os.path.exists(imagesDirectory):
        os.makedirs(imagesDirectory)
  
      outputImageName = "%s/%s.jpg" % (imagesDirectory, uniqueIdentifier)
      with open(outputImageName, 'wb') as output:
        output.write(artwork)
        output.close()
  except Exception, message:
    print "Problem saving image:", Exception, message
