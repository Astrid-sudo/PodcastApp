//
//  AudioPlayHelper.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

#import <AVFoundation/AVFoundation.h>
#import "GCDTimer.h"

@class AudioPlayHelper;

typedef NS_ENUM(NSInteger, PlayerState) {
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

/*!
 * @discussion Update current player item duration.
 * @param audioPlayHelper The AudioPlayHelper who ask delegate to update duration.
 * @param duration Current player item duration.
 */
- (void)updateDuration:(AudioPlayHelper *)audioPlayHelper duration:(CMTime)duration;

/*!
 * @discussion Update current player item current time.
 * @param audioPlayHelper The AudioPlayHelper who ask delegate to update current time.
 * @param currentTime Current player item current time.
 */
- (void)updateCurrentTime:(AudioPlayHelper *)audioPlayHelper currentTime:(CMTime)currentTime;

/*!
 * @discussion Notify AudioPlayHelperDelegate when current player item did play end.
 * @param audioPlayHelper The AudioPlayHelper who ask delegate to response play end.
 */
- (void)didPlaybackEnd:(AudioPlayHelper *)audioPlayHelper;

/*!
 * @discussion Toggle play button image when according to playerState.
 * @param audioPlayHelper The AudioPlayHelper who ask delegate to toggleButtonImage.
 * @param playerState avPlayer's playerState.
 */
- (void)toggleButtonImage:(AudioPlayHelper *)audioPlayHelper playerState:(NSInteger)playerState;


@end

@interface AudioPlayHelper : NSObject {
    PlayerState playerState;
}

// MARK: - properties

/*!
 * @discussion The avPlayer in AudioPlayHelper.
 */
@property (nonatomic ,strong) AVPlayer *avPlayer;

/*!
 * @discussion The gcdTimer to check whether play immediately or wait for player item loading.
 */
@property (nonatomic ,strong) GCDTimer* gcdTimer;

/*!
 * @discussion Delegate to recieve player state.
 */
@property (nonatomic, weak) id <AudioPlayHelperDelegate> delegate;

/*!
 * @discussion The timeObserverToken created when add addPeriodicTimeObserver.
 */
@property (nonatomic ,strong) id timeObserverToken;

// MARK: - method

/*!
 * @discussion For quickly access current time.
 * @return Current player item's current time
 */
- (CMTime)currentItemCurrentTime;

/*!
 * @discussion Return current player item's duration.
 * @return Current player item's duration.
 */
- (CMTime)currentItemDuration;

// MARK: - player item method

/*!
 * @discussion Create AVPlayer with url string.
 * @param urlString The url string which will create player item.
 */
- (void)configPlayer: (NSString*) urlString;

/*!
 * @discussion Replace current item with url string.
 * @param urlString The url string which will create player item.
 */
- (void)replaceCurrentItem: (NSString*) urlString;

/*!
 * @discussion Add observer to observe current player item status and play end.
 * @param currentPlayerItem The player item currently in avplayer .
 */
- (void)observePlayerItem: (AVPlayerItem*) currentPlayerItem;


/*!
 * @discussion The method triggered by NSNotificationCenter and will notify delegate when play end.
 * @param notification The notification sent by NSNotificationCenter.
 */
- (void)didPlaybackEnd:(NSNotification *)notification;

// MARK: - player method

/*!
 * @discussion Requests the periodic invocation to update current time by delegate.
 */
- (void)addPeriodicTimeObserver;

/*!
 * @discussion Cancels a previously registered periodic time observer.
 */
- (void)removePeriodicTimeObserver;

/*!
 * @discussion Ask avPlayer seek time according to slider value during value change.
 * @param sliderValue UISlider value
 */
- (void)slideToTime: (double) sliderValue;

/*!
 * @discussion Ask avPlayer seek time according to slider value when value end changing.
 * @param sliderValue UISlider value
 */
- (void)sliderTouchEnded: (double) sliderValue;

/*!
 * @discussion Set a timer to check if AVPlayerItem.isPlaybackLikelyToKeepUp. If yes, then will play, but if not, will recall this method again.
 * @param playerItem Current player item
 * @param player avPlayer
 */
- (void)bufferingForSeconds: (AVPlayerItem*) playerItem player: (AVPlayer*) player;

/*!
 * @discussion Pause avPlayer.(Call this method when buffering.)
 */
- (void)cancelPlay;

/*!
 * @discussion Play avPlayer, update player UI by delegate.
 */
- (void)playPlayer;

/*!
 * @discussion Pause avPlayer, update player UI by delegate.(Call this method when user's intention to pause player.)
 */
- (void)pausePlayer;

/*!
 * @discussion Determine play action according to playerState.
 */
- (void)togglePlay;

@end

