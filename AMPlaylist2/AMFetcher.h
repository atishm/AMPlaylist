//
//  AMFetcher.h
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol AMFetcherDelegate <NSObject>

-(void)didDownloadData:(NSMutableDictionary*)data;

@end

@interface AMFetcher : NSObject
- (void)fetchLatestPlaylists;
@property(nonatomic,assign)id<AMFetcherDelegate> delegate;
@end
