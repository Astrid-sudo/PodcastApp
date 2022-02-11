//
//  TimeCalculator.m
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import "TimeCalculator.h"

@implementation TimeCalculator

+ (NSString*)floatToTimecodeString: (float*) seconds {
    int time = roundf(*seconds);
    int hours = time / 3600;
    int minutes = time / 60 - hours * 60;
    int secs = time % 60;
    return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, secs];
}

@end
