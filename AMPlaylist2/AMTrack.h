//
//  AMTrack.h
//  Playlists
//
//  Created by Atish Mehta on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AMTrack : NSObject

@property(nonatomic, copy)NSString *title;
@property(nonatomic, copy)NSString *artist;
@property(nonatomic, copy)NSString *bpm;
@property(nonatomic, copy)NSString *time;
@property(nonatomic, copy)NSString *label;
@property(nonatomic, copy)NSString *comment;
@property(nonatomic, copy)NSString *discName;
@property(nonatomic, assign)int trackNumber;
@property(nonatomic, copy)NSString *key;
@property(nonatomic, copy)NSString *fileName;
@property(nonatomic, assign)CGFloat rating;
@end
