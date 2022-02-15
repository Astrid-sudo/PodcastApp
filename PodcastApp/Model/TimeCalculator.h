//
//  TimeCalculator.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>

NS_ASSUME_NONNULL_BEGIN

@interface TimeCalculator : NSObject

/*!
 * @discussion Transfer seconds from float to timecode String.
 * @param seconds Seconds in float.
 * @return Timecode string.
 */
+ (NSString*)floatToTimecodeString: (float) seconds;

@end

NS_ASSUME_NONNULL_END
