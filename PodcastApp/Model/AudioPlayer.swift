//
//  AudioPlayer.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import AVFoundation

enum PlayerState {
    case unknow
    case readyToPlay
    case playing
    case buffering
    case failed
    case pause
    case ended
}

protocol AudioPlayerProtocol: AnyObject {
    func updateDuration(_ audioPlayer: AudioPlayer, duration: CMTime)
    func updateCurrentTime(_ audioPlayer: AudioPlayer, currentTime: CMTime)
    func didPlaybackEnd(_ audioPlayer: AudioPlayer)
    func togglePlayButtonImage(_ audioPlayer: AudioPlayer, playButtonType: PlayButtonType)
}

class AudioPlayer {
    
    // MARK: - Properties
    
    private(set) var avPlayer: AVPlayer?
    
    var playerState: PlayerState = .unknow
    
    var gcdTimer: GCDTimer?
    
    var timeObserverToken: Any?
    
    var statusObserve: NSKeyValueObservation?
    
    weak var delegate: AudioPlayerProtocol?
    
    deinit {
        print("AudioPlayer Deinit")
    }
    
    // MARK: - method
    
    func currentItemCurrentTime() -> CMTime? {
        guard let currentItem = avPlayer?.currentItem else { return nil }
        return currentItem.currentTime()
    }
    
    func currentItemDuration() -> CMTime? {
        guard let currentItem = avPlayer?.currentItem else { return nil }
        return currentItem.duration
    }
    
    // MARK: - player item method
    
    /// Create player in AudioPlayer with url string. This method also observe player item's status, didPlayEnd.
    /// - Parameter urlString: The first player item in player.
    func configQueuePlayer(_ urlString: String) {
        guard let url = URL(string: urlString) else { return }
        avPlayer = AVPlayer(url: url)
        observePlayerItem(currentPlayerItem: avPlayer?.currentItem)
    }
    
    func replaceCurrentItem(with urlString: String) {
        guard let url = URL(string: urlString) else { return }
        let playerItem = AVPlayerItem(url: url)
        DispatchQueue.main.async {
            self.avPlayer?.replaceCurrentItem(with: playerItem)
            self.observePlayerItem(currentPlayerItem: self.avPlayer?.currentItem)
        }
    }
    
    /// Access AVPlayerItem duration once AVPlayerItem is loaded
    func observeItemStatus(currentPlayerItem: AVPlayerItem?) {
        guard let currentPlayerItem = currentPlayerItem else { return }
        statusObserve = currentPlayerItem.observe(\.status, options: [.initial, .new]) { [weak self] _, _ in
            guard let self = self else { return }
            self.delegate?.updateDuration(self, duration: currentPlayerItem.duration)
        }
    }
    
    /// Observe player item did play end.
    func observeItemPlayEnd(currentPlayerItem: AVPlayerItem?) {
        NotificationCenter.default.addObserver(self, selector: #selector(didPlaybackEnd), name: .AVPlayerItemDidPlayToEndTime, object: currentPlayerItem)
    }
    
    /// Observe player item buffering, status and play end.
    func observePlayerItem(previousPlayerItem: AVPlayerItem? = nil, currentPlayerItem: AVPlayerItem?) {
        self.observeItemStatus(currentPlayerItem: currentPlayerItem)
        self.observeItemPlayEnd(currentPlayerItem: currentPlayerItem)
    }
    
    /// Tell the delegate didPlaybackEnd.
    @objc func didPlaybackEnd() {
        playerState = .ended
        delegate?.didPlaybackEnd(self)
    }
    
    // MARK: - player method
    
    /// Start observe currentTime.
    func addPeriodicTimeObserver() {
        guard let avPlayer = avPlayer else { return }
        // Invoke callback every half second
        let interval = CMTime(seconds: 0.5,
                              preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        // Add time observer. Invoke closure on the main queue.
        timeObserverToken =
        avPlayer.addPeriodicTimeObserver(forInterval: interval, queue: .main) {
            [weak self] time in
            guard let self = self else { return }
            // update player transport UI
            self.delegate?.updateCurrentTime(self, currentTime: time)
        }
    }
    
    /// Stop observe currentTime.
    func removePeriodicTimeObserver() {
        guard let avPlayer = avPlayer else { return }
        if let token = timeObserverToken {
            avPlayer.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    /// Call this method when user is in the process of dragging progress bar slider.
    func slideToTime(_ sliderValue: Double) {
        guard let avPlayer = avPlayer,
              let currentItem = avPlayer.currentItem else { return }
        let duration = currentItem.duration
        let seekCMTime = CMTimeMultiplyByFloat64(duration, multiplier: sliderValue)
        avPlayer.seek(to: seekCMTime)
        delegate?.updateCurrentTime(self, currentTime: seekCMTime)
    }
    
    /// Call this method when user end dragging progress bar slider.
    func sliderTouchEnded(_ sliderValue: Double) {
        guard let avPlayer = avPlayer,
              let currentItem = avPlayer.currentItem else { return }
        let currentItemDuration = currentItem.duration
        
        // Drag to the end of the progress bar.
        if sliderValue == 1 {
            delegate?.updateCurrentTime(self, currentTime: currentItemDuration)
            delegate?.togglePlayButtonImage(self, playButtonType: .play)
            playerState = .ended
            removePeriodicTimeObserver()
            return
        }

        // Drag to middle and is likely to keep up.
        if currentItem.isPlaybackLikelyToKeepUp {
            playPlayer()
            return
        }

        // Drag to middle, but needs time buffering.
        bufferingForSeconds(playerItem: currentItem, player: avPlayer)
    }
    
    /// Set a timer to check if AVPlayerItem.isPlaybackLikelyToKeepUp. If yes, then will play, but if not, will recall this method again.
    func bufferingForSeconds(playerItem: AVPlayerItem, player: AVPlayer) {
        guard playerItem.status == .readyToPlay,
              playerState != .failed else { return }
        self.cancelPlay(player: player)
        playerState = .buffering
        gcdTimer = GCDTimer(timeout: 3.0, repeat: false, completion: { [weak self] in
            guard let self = self else { return }
            if playerItem.isPlaybackLikelyToKeepUp {
                self.playPlayer()
            } else {
                self.bufferingForSeconds(playerItem: playerItem, player: player)
            }
        }, queue: .main)
        gcdTimer?.start()
    }

    
    /// Pause player, let player control keep existing on screen.(Call this method when buffering.)
    func cancelPlay(player: AVPlayer) {
        guard let avPlayer = avPlayer else { return }
        avPlayer.pause()
        playerState = .pause
        gcdTimer?.invalidate()
    }
    
    /// Play player, update player UI.
    func playPlayer() {
        guard let avPlayer = avPlayer else { return }
        avPlayer.play()
        self.playerState = .playing
        self.addPeriodicTimeObserver()
        self.delegate?.togglePlayButtonImage(self, playButtonType: .pause)
    }
    
    /// Pause player, update player UI.(Call this method when user's intension to pause player.)
    func pausePlayer() {
        guard let avPlayer = avPlayer else { return }
        avPlayer.pause()
        playerState = .pause
        removePeriodicTimeObserver()
        self.delegate?.togglePlayButtonImage(self, playButtonType: .play)
    }
    
    /// Determine play action according to playerState.
    func togglePlay() {
        switch playerState {
            
        case .buffering, .unknow, .pause, .readyToPlay, .ended:
            playPlayer()
            
        case .playing:
            pausePlayer()
            
        default:
            break
        }
    }
    
    func releasePlayer() {
        avPlayer = nil
        gcdTimer = nil
        timeObserverToken = nil
        statusObserve = nil
    }
    
}

