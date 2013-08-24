//
//  TrackCell.m
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/16/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TrackCell.h"

@implementation TrackCell

@synthesize artist = _artist;
@synthesize trackNumber = _trackNumber;
@synthesize bpm = _bpm;
@synthesize comment = _comment;
@synthesize track = _track;
@synthesize discName = _discName;
@synthesize gesture = _gesture;



- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
