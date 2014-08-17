//
//  AMTrack.m
//  Playlists
//
//  Created by Atish Mehta on 8/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AMTrack.h"

@implementation AMTrack

- (NSString *)description
{
  return [NSString stringWithFormat:@"%@ %@ %@", _title, _artist, _comment];
}
@end
