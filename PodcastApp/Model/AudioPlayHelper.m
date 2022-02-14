//
//  AudioPlayHelper.m
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import "AudioPlayHelper.h"


@implementation AudioPlayHelper


- (void)dealloc {
    if (_gcdTimer != nil) {
        [_gcdTimer invalidate];
        _gcdTimer = nil;
    }
    [_avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
    [_avPlayer removeTimeObserver:_timeObserverToken];
    _timeObserverToken = nil;
    _avPlayer = nil;
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// MARK: - method

- (CMTime)currentItemCurrentTime {
    return _avPlayer.currentItem.currentTime;
}

- (CMTime)currentItemDuration {
    return _avPlayer.currentItem.duration;
}

// MARK: - player item method

- (void)configPlayer: (NSString*) urlString {
    NSURL *url = [NSURL URLWithString:urlString];
    _avPlayer = [[AVPlayer alloc] initWithURL:url];
    [self observePlayerItem:_avPlayer.currentItem];
}

- (void)replaceCurrentItem: (NSString*) urlString {
    [self pausePlayer];
    NSURL *url = [NSURL URLWithString:urlString];
    AVPlayerItem *playerItem = [[AVPlayerItem alloc] initWithURL:url];
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [_avPlayer.currentItem removeObserver:self forKeyPath:@"status"];
        [_avPlayer replaceCurrentItemWithPlayerItem:playerItem];
        [self observePlayerItem:_avPlayer.currentItem];
    });
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
change:(NSDictionary *)change context:(void *)context {
    if([keyPath isEqualToString:@"status"]) {
        [_delegate updateDuration:self duration:_avPlayer.currentItem.duration];
    }
};

- (void)observePlayerItem: (AVPlayerItem*) currentPlayerItem {
    [currentPlayerItem addObserver:self forKeyPath:@"status" options: NSKeyValueObservingOptionInitial|NSKeyValueObservingOptionNew  context:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(didPlaybackEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:currentPlayerItem];
}

- (void)didPlaybackEnd:(NSNotification *)notification {
    __weak typeof(self) weakSelf = self;
    playerState = PlayerStateEnded;
    [_delegate toggleButtonImage:self playerState:playerState];
    [_delegate didPlaybackEnd:weakSelf];
}

// MARK: - player method

- (void)addPeriodicTimeObserver {
    __weak AudioPlayHelper *weakSelf = self;
    CMTime interval = CMTimeMakeWithSeconds(0.5, NSEC_PER_SEC);
    dispatch_queue_t mainQueue = dispatch_get_main_queue();
    self.timeObserverToken =
    [_avPlayer addPeriodicTimeObserverForInterval:interval
                                                  queue:mainQueue
                                             usingBlock:^(CMTime time) {
        [weakSelf.delegate updateCurrentTime:weakSelf currentTime:time];
        }];
}

- (void)removePeriodicTimeObserver {
    if (self.timeObserverToken) {
        [_avPlayer removeTimeObserver:self.timeObserverToken];
        self.timeObserverToken = nil;
    }
}

- (void)slideToTime: (double) sliderValue {
    CMTime duration = _avPlayer.currentItem.duration;
    CMTime seekCMTime = CMTimeMultiplyByFloat64(duration, sliderValue);
    [_avPlayer seekToTime:seekCMTime];
    [_delegate updateCurrentTime:self currentTime:seekCMTime];
}

- (void)sliderTouchEnded: (double) sliderValue {
    
    CMTime duration = _avPlayer.currentItem.duration;
    
    // Drag to the end of the progress bar.
    if (sliderValue == 1.0) {
        [_delegate updateCurrentTime:self currentTime:duration];
        playerState = PlayerStateEnded;
        [_delegate toggleButtonImage:self playerState:playerState];
        [self removePeriodicTimeObserver];
        return;
    }
    
    // Drag to middle and is likely to keep up.
    if (_avPlayer.currentItem.isPlaybackLikelyToKeepUp) {
        [self playPlayer];
        return;
    }
    
    // Drag to middle, but needs time buffering.
    [self bufferingForSeconds:_avPlayer.currentItem player:_avPlayer];
}

- (void)bufferingForSeconds: (AVPlayerItem*) playerItem player: (AVPlayer*) player {
    __weak AudioPlayHelper *weakSelf = self;
    if (playerState != PlayerStateFailed && playerItem.status == PlayerStateReadyToPlay) {
        [self cancelPlay];
        playerState = PlayerStateBuffering;
        _gcdTimer = [[GCDTimer alloc] initWithTimeout:3.0 repeat:false completion:^{
            if (weakSelf.avPlayer.currentItem.isPlaybackLikelyToKeepUp) {
                [weakSelf playPlayer];
            } else {
                [weakSelf bufferingForSeconds: weakSelf.avPlayer.currentItem player: weakSelf.avPlayer];
            }
        } queue:dispatch_get_main_queue()];
    }
}

- (void)cancelPlay {
    [_avPlayer pause];
    playerState = PlayerStatePause;
    [_gcdTimer invalidate];
}

- (void)playPlayer {
    [_avPlayer play];
    playerState = PlayerStatePlaying;
    [self addPeriodicTimeObserver];
    [_delegate toggleButtonImage:self playerState:playerState];
}

- (void)pausePlayer {
    [_avPlayer pause];
    playerState = PlayerStatePause;
    [self removePeriodicTimeObserver];
    [_delegate toggleButtonImage:self playerState:playerState];
}

- (void)togglePlay {
    
    switch (playerState) {
            
        case PlayerStateUnknow:
            [self playPlayer];
            break;
            
        case PlayerStateReadyToPlay:
            [self playPlayer];
            break;
            
        case PlayerStatePlaying:
            [self pausePlayer];
            break;
            
        case PlayerStateBuffering:
            [self playPlayer];
            break;
            
        case PlayerStateFailed:
            [self playPlayer];
            break;
            
        case PlayerStatePause:
            [self playPlayer];
            break;
            
        case PlayerStateEnded:
            [self playPlayer];
            break;
    }
}


@end
