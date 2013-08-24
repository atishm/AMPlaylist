//
//  AMFetcher.m
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMFetcher.h"
#import "AMTrack.h"

@interface AMFetcher ()
@property(nonatomic, retain) NSMutableData *receivedData;
@end

@implementation AMFetcher

@synthesize receivedData = _receivedData;
@synthesize delegate = _delegate;
-(void)fetchLatestPlaylists {
  // Create the request.
  NSURLRequest *theRequest=[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://www.atish.net/playlists.txt"]
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
  
  int numPlaylists =0;
  int numTracks = 0;
  for (NSString *line in items) {
    NSArray *fields = [line componentsSeparatedByString:@"\t"];
    if (fields.count == 1) {
      
      playlistName = [fields objectAtIndex:0];
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
        NSString *number = [fields objectAtIndex:0];
        if ([number isEqualToString:@"#"]) {
          continue;
        }
        NSString *title = [fields objectAtIndex:1];
        NSString *time = [fields objectAtIndex:2];
        NSString *artist = [fields objectAtIndex:3];
        NSString *bpm = [NSString stringWithFormat:@"%d", [[fields objectAtIndex:4] intValue]];
        NSString *comment = [fields objectAtIndex:5];
        NSString *key = @"x";
        if (fields.count > 6) {
          key = [fields objectAtIndex:6];
        }
        
        //trim whitespace and remove 'm'...assume minor
        key = [key stringByReplacingOccurrencesOfString:@" " withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"min" withString:@""];
        key = [key stringByReplacingOccurrencesOfString:@"maj" withString:@"M"];
        key = [key stringByReplacingOccurrencesOfString:@"m" withString:@""];
        
        AMTrack *track = [[AMTrack alloc] init];
        track.title = title;
        track.time = time;
        track.artist = artist;
        track.bpm = bpm;
        track.comment = comment;
        track.trackNumber = trackNum++;
        track.discName = playlistName;
        track.key = key;
        [tracks addObject:track];
        numTracks++;
      } else {
        NSLog(@"skipping track because playlist name is nil");
      }
    }
  }
  NSLog(@"numPlaylists: %d, numTracks: %d", numPlaylists, numTracks);
  
  // release the connection, and the data object
  [_delegate didDownloadData:allData];
  connection = nil;
  self.receivedData = nil;
}
@end
