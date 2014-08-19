import mutagen
from mutagen.id3 import ID3
from mutagen import File

def getImagePathForMp3(pathToMp3, uniqueIdentifier,directory):
  file = File(pathToMp3) # mutagen can automatically detect format and type of tags
  artwork = file.tags['APIC:'].data
  
  outputImageName = "%s/%s.jpg" % (directory, uniqueIdentifier)
  with open(outputImageName, 'wb') as output:
    output.write(artwork)
    output.close()