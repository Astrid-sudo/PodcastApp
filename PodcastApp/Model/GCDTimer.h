//
//  GCDTimer.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import <Foundation/Foundation.h>

@interface GCDTimer: NSObject

@property (nonatomic, readonly) NSTimeInterval timeoutDate;
- (instancetype)initWithTimeout:(NSTimeInterval)timeout
               repeat:(bool)repeats
           completion:(dispatch_block_t)completion
                queue:(dispatch_queue_t)queue;

- (void)start;
- (void)invalidate;
- (void)resetTimeout:(NSTimeInterval)timeout;

@end
