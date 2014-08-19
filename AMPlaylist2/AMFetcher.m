//
//  AMFetcher.m
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMFetcher.h"
#import "AMTrack.h"
#import "AMConstants.h"
#import "ImageDownloader.h"

@interface AMFetcher ()
@property(nonatomic, retain) NSMutableData *receivedData;
@end

@implementation AMFetcher

@synthesize receivedData = _receivedData;
@synthesize delegate = _delegate;

-(void)fetchLatestPlaylists {
  // Create the request.
  NSString *urlString = [NSString stringWithFormat:@"%@/%@", kURLPrefix, kPlaylistFileName];
  NSURLRequest *theRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]
                                              cachePolicy:NSURLRequestReloadIgnoringLocalCacheData
                                          timeoutInterval:60.0];
  // create the connection with the request
  // and start loading the data
  NSURLConnection *theConnection = [[NSURLConnection alloc] initWithRequest:theRequest delegate:self];
  if (theConnection) {
    // Create the NSMutableData to hold the received data.
    // receivedData is an instance variable declared elsewhere.
    _receivedData = [NSMutableData data];
  } else {
    NSLog(@"Connection failed");
    // Inform the user that the connection failed.
  }
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
  // receivedData is an instance variable declared elsewhere.
  [_receivedData setLength:0];
}


- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
  // Append the new data to receivedData.
  // receivedData is an instance variable declared elsewhere.
  [_receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
  
  connection = nil;
  // receivedData is declared as a method instance elsewhere
  self.receivedData = nil;
  
  // inform the user
  NSLog(@"Connection failed! Error - %@ %@",
        [error localizedDescription],
        [[error userInfo] objectForKey:NSURLErrorFailingURLStringErrorKey]);
}

const CGFloat kLinePlaylistName = 0;

const CGFloat kLineIndexTitle = 0;
const CGFloat kLineIndexTime = 1;
const CGFloat kLineIndexArtist = 2;
const CGFloat kLineIndexBpm = 3;
const CGFloat kLineIndexComment = 4;
const CGFloat kLineIndexKey = 5;
const CGFloat kLineIndexFileName = 6;

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
  
  NSAssert([NSThread isMainThread], @"Method called using a thread other than main!");
  
  // do something with the data
  // receivedData is declared as a method instance elsewhere
  NSLog(@"Succeeded! Received %d bytes of data",[_receivedData length]);
  NSString *dataString = [[NSString alloc] initWithData:_receivedData encoding:NSUTF8StringEncoding];
  
  
  NSMutableDictionary *allData = [NSMutableDictionary dictionary];
  NSString* delimiter = @"\n";
  NSArray* items = [dataString componentsSeparatedByString:delimiter];
  
  NSString *playlistName = nil;
  int trackNum = 1;
  
  int numPlaylists = 0;
  int numTracks = 0;
  
  NSMutableArray *imagesToDownload = [NSMutableArray array];
  for (NSString *line in items) {
    NSArray *fields = [line componentsSeparatedByString:@"\t"];
    if (fields.count == 1) {
      
      playlistName = [fields objectAtIndex:kLinePlaylistName];
      playlistName = [playlistName stringByTrimmingCharactersInSet:
                                 [NSCharacterSet whitespaceAndNewlineCharacterSet]];
      
      if (playlistName.length > 0) {
        [allData setObject:[NSMutableArray array] forKey:playlistName];
        trackNum = 1;
      }
      numPlaylists++;
    } else {
      if (playlistName) {
        NSMutableArray *tracks = [allData objectForKey:playlistName];
        /*
        NSString *number = [fields objectAtIndex:0];
        if ([number isEqualToString:@"#"]) {
          continue;
        }
         */
        trackNum++;
         
        NSString *title = [fields objectAtIndex:kLineIndexTitle];
        NSString *time = [fields objectAtIndex:kLineIndexTime];
        NSString *artist = [fields objectAtIndex:kLineIndexArtist];
        NSString *bpm = [NSString stringWithFormat:@"%d", [[fields objectAtIndex:kLineIndexBpm] intValue]];
        NSString *comment = [fields objectAtIndex:kLineIndexComment];
        NSString *key = @"x";
        if (fields.count > kLineIndexKey) {
          key = [fields objectAtIndex:kLineIndexKey];
        }
        
        //trim whitespace and remove 'm'...assume minor
        key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"min" withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"maj" withString:@"M"];
        key = [key stringByReplacingOccurrencesOfString:@"m" withString:@""];
        
        NSString *fileName = [fields objectAtIndex:kLineIndexFileName];
        NSRange range = [fileName rangeOfString:@"^\\s*" options:NSRegularExpressionSearch];
        NSString *fileNameTrimmed = [fileName stringByReplacingCharactersInRange:range withString:@""];
        [imagesToDownload addObject:fileNameTrimmed];
        
        AMTrack *track = [[AMTrack alloc] init];
        track.title = title;
        track.time = time;
        track.artist = artist;
        track.bpm = bpm;
        track.comment = comment;
        track.trackNumber = trackNum++;
        track.discName = playlistName;
        track.key = key;
        track.fileName = fileNameTrimmed;
        [tracks addObject:track];
        NSLog(@"added track %@", track);
        numTracks++;
      } else {
        NSLog(@"skipping track because playlist name is nil");
      }
    }
  }
  NSLog(@"numPlaylists: %d, numTracks: %d", numPlaylists, numTracks);
  
  ImageDownloader *imageDownloader = [[ImageDownloader alloc] init];
  [imageDownloader downloadImages:imagesToDownload];
  
  // release the connection, and the data object
  [_delegate didDownloadData:allData];
  connection = nil;
  self.receivedData = nil;
}
@end
