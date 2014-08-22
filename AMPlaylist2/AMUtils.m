//
//  AMUtils.m
//  AMPlaylist2
//
//  Created by Atish Mehta on 8/22/14.
//
//

#import "AMUtils.h"

@implementation AMUtils

+ (NSString *)imagePathWithName:(NSString *)imageName
{
  return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:imageName];
  
}

+ (UIImage *)imageWithName:(NSString *)imageName
{
  return [UIImage imageWithContentsOfFile:[self imagePathWithName:imageName]];
}
@end
