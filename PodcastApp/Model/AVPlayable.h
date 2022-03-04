//
//  AVPlayable.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/14.
//

#import <AVFoundation/AVFoundation.h>
#import "GCDTimer.h"

@protocol  AVPlayable;

typedef NS_ENUM(NSInteger, PlayerState) {
    PlayerStateUnknow,
    PlayerStateReadyToPlay,
    PlayerStatePlaying,
    PlayerStateBuffering,
    PlayerStateFailed,
    PlayerStatePause,
    PlayerStateEnded,
};

// MARK: - AVPlayableDelegate

@protocol AVPlayableDelegate <NSObject>
@required
- (void)updateDuration:(id<AVPlayable>)audioPlayHelper duration:(CMTime)duration;
- (void)updateCurrentTime:(id<AVPlayable>)audioPlayHelper currentTime:(CMTime)currentTime;
- (void)didPlaybackEnd:(id<AVPlayable>)audioPlayHelper;
- (void)toggleButtonImage:(id<AVPlayable>)audioPlayHelper playerState:(NSInteger)playerState;
@end

// MARK: - AVPlayable

@protocol AVPlayable <NSObject>

@required
@property (nonatomic ,strong) AVPlayer *avPlayer;
@property (nonatomic ,strong) id timeObserverToken;
@property (nonatomic ,strong) GCDTimer* gcdTimer;
@property (nonatomic ,strong) id statusObserve;
@property (nonatomic, weak) id <AVPlayableDelegate> delegate;
@property (nonatomic) PlayerState playerState;

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


