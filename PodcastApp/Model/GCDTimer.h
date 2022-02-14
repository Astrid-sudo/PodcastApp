//
//  GCDTimer.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import <Foundation/Foundation.h>

@interface GCDTimer: NSObject

/*!
 * @discussion Timeout date time interval.
 */
@property (nonatomic, readonly) NSTimeInterval timeoutDate;

/*!
 * @discussion Provide an instance of GCDTimer.
 * @param timeout The number of seconds between firings of the timer.
 * @param repeats If true, the timer will reschedule itself until invalidated. If false, the timer will be invalidated after it fires.
 * @param completion The execution of the timer.
 * @param queue The dispatch queue for executing the completion.
 * @return An instance of GCDTimer with given values.
 */
- (instancetype)initWithTimeout:(NSTimeInterval)timeout
               repeat:(bool)repeats
           completion:(dispatch_block_t)completion
                queue:(dispatch_queue_t)queue;
/*!
 * @discussion Start GCDtimer.
 */
- (void)start;

/*!
 * @discussion Invalidate GCDtimer.
 */
- (void)invalidate;

/*!
 * @discussion Reschedule the timer with new timeout value.
 */
- (void)resetTimeout:(NSTimeInterval)timeout;

@end
