//
//  GCDTimer.m
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import "GCDTimer.h"

#define weakify(var) __weak typeof(var) weak_##var = var;
#define strongify(var) \
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Wshadow\"") \
__strong typeof(var) var = weak_##var; \
_Pragma("clang diagnostic pop")

@interface GCDTimer ()

@property (nonatomic) dispatch_source_t timer;
@property (nonatomic, readwrite) NSTimeInterval timeoutDate;
@property (nonatomic) NSTimeInterval timeout;
@property (nonatomic) NSTimeInterval timeoutAfterResume;
@property (nonatomic) bool repeat;
@property (nonatomic, copy) dispatch_block_t completion;
@property (nonatomic) dispatch_queue_t queue;

@end

@implementation GCDTimer

@synthesize timeoutDate = _timeoutDate;
@synthesize timer = _timer;
@synthesize timeout = _timeout;
@synthesize repeat = _repeat;
@synthesize completion = _completion;
@synthesize queue = _queue;

- (id)initWithTimeout:(NSTimeInterval)timeout
               repeat:(bool)repeats
           completion:(dispatch_block_t)completion
                queue:(dispatch_queue_t)queue {
    self = [super init];
    if (self != nil) {
        _timeoutDate = INT_MAX;
        _timeout = timeout;
        _repeat = repeats;
        self.completion = completion;
        self.queue = queue;
    }
    return self;
}

+ (GCDTimer *)scheduledTimerWithTimeInterval:(NSTimeInterval)timeout
                                     repeats:(BOOL)repeats
                                  completion:(dispatch_block_t)completion
                                       queue:(dispatch_queue_t)queue {
    return [[GCDTimer alloc] initWithTimeout:timeout
                                      repeat:repeats
                                  completion:completion
                                       queue:queue];
}

- (void)dealloc {
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)start {
    _timeoutDate = CFAbsoluteTimeGetCurrent() + kCFAbsoluteTimeIntervalSince1970 + _timeout;
    
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _queue);
    dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_timeout * NSEC_PER_SEC)), _repeat ? (int64_t)(_timeout * NSEC_PER_SEC) : DISPATCH_TIME_FOREVER, 0);
    
    
    weakify(self)
    dispatch_source_set_event_handler(_timer, ^{
                                          strongify(self)
                                          if (self.completion)
                                              self.completion();
                                          if (!_repeat)
                                          {
                                              [self invalidate];
                                          }
                                      });
    dispatch_resume(_timer);
}

- (void)invalidate {
    _timeoutDate = 0;
    
    if (_timer != nil) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
}

- (void)resetTimeout:(NSTimeInterval)timeout {
    [self invalidate];
    _timeout = timeout;
    [self start];
}


@end
