//
//  ImageDownloader.m
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/18/14.
//
//

#import "ImageDownloader.h"
#import "AMConstants.h"
#import "AMUtils.h"

@implementation ImageDownloader
- (void)downloadImages:(NSArray *)imageNames
{
  for (NSString *imageName in imageNames) {
    NSString *imageNameJpg = [NSString stringWithFormat:@"%@.jpeg", imageName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:[AMUtils imagePathWithName:imageNameJpg] isDirectory:NO]) {
      NSLog(@"skipping d/l of %@: it already exists", imageNameJpg);
      continue;
    }
    
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", kURLPrefix, kPlaylistImageDir, imageNameJpg];


    NSData *imageData = [[NSData alloc] initWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:urlString]]];
    NSLog(@"url: [%@] name: [%@] size: [%d]", urlString, imageName, imageData.length);
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    
    NSString *databasePath = [[NSString alloc] initWithString: [docsDir stringByAppendingPathComponent:imageNameJpg]];
    [imageData writeToFile:databasePath atomically:YES];
  }
}
@end
