//
//  AudioPlayHelper.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import <AVFoundation/AVFoundation.h>
#import "GCDTimer.h"

//NS_ASSUME_NONNULL_BEGIN

@class AudioPlayHelper;

typedef NS_ENUM(NSUInteger, PlayerState) {
    PlayerStateUnknow,
    PlayerStateReadyToPlay,
    PlayerStatePlaying,
    PlayerStateBuffering,
    PlayerStateFailed,
    PlayerStatePause,
    PlayerStateEnded,
};

@protocol AudioPlayHelperDelegate <NSObject>
@required

- (void)toggleButtonImage:(AudioPlayHelper *)audioPlayHelper playerState:(NSString*)playerState;

- (void)updateDuration:(AudioPlayHelper *)audioPlayHelper duration:(CMTime)duration;

- (void)updateCurrentTime:(AudioPlayHelper *)audioPlayHelper currentTime:(CMTime)currentTime;

- (void)didPlaybackEnd:(AudioPlayHelper *)audioPlayHelper;

@end

@interface AudioPlayHelper : NSObject {
    PlayerState playerState;
}

// MARK: - properties

@property (nonatomic ,strong) AVPlayer *avPlayer;
@property (nonatomic ,strong) id timeObserverToken;
@property (nonatomic ,strong) GCDTimer* gcdTimer;
@property (nonatomic ,strong) id statusObserve;
@property (nonatomic, weak) id <AudioPlayHelperDelegate> delegate;

// MARK: - method

- (CMTime)currentItemCurrentTime;
- (CMTime)currentItemDuration;

// MARK: - player item method

- (void)configPlayer: (NSString*) urlString;
- (void)replaceCurrentItem: (NSString*) urlString;
- (void)observeItemStatus: (AVPlayerItem*) currentPlayerItem;
- (void)observeItemPlayEnd: (AVPlayerItem*) currentPlayerItem;
- (void)observePlayerItem: (AVPlayerItem*) currentPlayerItem;
- (void)didPlaybackEnd:(NSNotification *)notification;
// MARK: - player method

- (void)addPeriodicTimeObserver;
- (void)removePeriodicTimeObserver;
- (void)slideToTime: (double) sliderValue;
- (void)sliderTouchEnded: (double) sliderValue;
- (void)bufferingForSeconds: (AVPlayerItem*) playerItem player: (AVPlayer*) player;
- (void)cancelPlay: (AVPlayer*) player;
- (void)playPlayer;
- (void)pausePlayer;
- (void)togglePlay;

@end

//NS_ASSUME_NONNULL_END
