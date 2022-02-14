//
//  PlayerPageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import CoreMedia

class PlayerPageViewModel: NSObject {
    
    // MARK: - properties be observed
    
    let epTitle: Box<String> = Box("")
    let epImage: Box<UIImage> = Box(UIImage())
    let playButtonType: Box<PlayButtonType> = Box(.play)
    let playProgress: Box<Float> = Box(.zero)
    let currentTime = Box("")
    let duration = Box("")
    
    // MARK: - properties
    
    var playerDetails = [PlayerDetail]()
    var currentEpisodeIndex = 0
    var audioLink = ""
    
    private lazy var audioPlayHelper: AudioPlayHelper = {
        let audioPlayHelper = AudioPlayHelper()
        audioPlayHelper.delegate = self
        return audioPlayHelper
    }()
    
    // MARK: - init / deinit
    
    init(playerDetails: [PlayerDetail], currentEpisodeIndex: Int) {
        self.playerDetails = playerDetails
        self.currentEpisodeIndex = currentEpisodeIndex
        super.init()
        parsePlayerDetail()
        configPlayer()
    }
    
    deinit {
        print("PlayerPageViewModel Deinit")
    }
    
    // MARK: - method
    
    /// Parse PlayerDetail and store in local properties.
    func parsePlayerDetail() {
        guard playerDetails.count > currentEpisodeIndex else { return }
        let currentPlayerDetail = playerDetails[currentEpisodeIndex]
        guard let epTitle = currentPlayerDetail.epTitle,
              let epImage = currentPlayerDetail.epImage,
              let audioLinkUrl = currentPlayerDetail.audioLinkUrl else { return }
        
        self.epTitle.value = epTitle
        self.epImage.value = epImage
        self.audioLink = audioLinkUrl
    }
    
    /// Configure audioPlayHelper by audioLinkUrl.
    private func configPlayer() {
        guard let audioLinkUrl = playerDetails[currentEpisodeIndex].audioLinkUrl else { return }
        audioPlayHelper.configPlayer(audioLinkUrl)
    }
    
    /// Change current time.
    /// - Parameter currentTime: Current currentTime from audioPlayHelper.
    func changeCurrentTime(currentTime: CMTime) {
        let currenTimeSeconds = Float(CMTimeGetSeconds(currentTime))
        self.currentTime.value = TimeCalculator.float(toTimecodeString: currenTimeSeconds)
    }
    
    /// Change duration.
    /// - Parameter duration: Current duration from audioPlayHelper.
    func changeDuration(duration: CMTime) {
        let durationSeconds = Float(CMTimeGetSeconds(duration))
        self.duration.value = TimeCalculator.float(toTimecodeString: durationSeconds)
    }
    
    /// Change play progress.
    /// - Parameter currentTime: Current currentTime from audioPlayHelper.
    /// - Parameter duration: Current duration from audioPlayHelper.
    func changeProgress(currentTime: CMTime, duration: CMTime) {
        guard duration >= currentTime else { return }
        let currenTime = CMTimeGetSeconds(currentTime)
        let duration = CMTimeGetSeconds(duration)
        self.playProgress.value = Float(currenTime / duration)
    }
    
    // MARK: - player method
    
    /// Ask audioPlayHelper togglePlay.
    func togglePlay() {
        audioPlayHelper.togglePlay()
    }
    
    /// Tell if user want to proceed to next or previous item.
    /// - Parameter switchType: next or previous item.
    func switchToItem(_ switchType: SwitchItemType) {
        switch switchType {
        case .next:
            proceedToNextItem()
        case .previous:
            proceedToPreviousItem()
        }
    }
    
    /// Ask audioPlayHelper slide to time according to progress bar value during value changed.
    /// - Parameter sliderValue: Progress bar value.
    func slideToTime(_ sliderValue: Double) {
        audioPlayHelper.slide(toTime: sliderValue)
    }
    
    /// Ask audioPlayHelper slide to time according to progress bar value when value changed end.
    /// - Parameter sliderValue: Progress bar value.
    func sliderTouchEnded(_ sliderValue: Double) {
        audioPlayHelper.sliderTouchEnded(sliderValue)
    }
    
    /// Ask audioPlayHelper to pausePlayer.
    func pausePlayer() {
        audioPlayHelper.pausePlayer()
    }
    
    /// If current episode is not the last episode, proceed to play the next episode. If it is the last episode, then keep this episode in player.
    func proceedToNextItem() {
        if currentEpisodeIndex > 0 {
            currentEpisodeIndex -= 1
            proceedToEpisode(ep: currentEpisodeIndex)
            audioPlayHelper.playPlayer()
        } else {
            if let audioLink = playerDetails[0].audioLinkUrl {
                keepCurrentEpisode(with: audioLink)
            }
        }
    }
    
    /// If current episode is not the first episode, proceed to play the previous episode. If it is the first episode, then keep this episode in player.
    func proceedToPreviousItem() {
        if playerDetails.count - 1 > currentEpisodeIndex {
            currentEpisodeIndex += 1
            proceedToEpisode(ep: currentEpisodeIndex)
            audioPlayHelper.playPlayer()
        } else {
            if let audioLink = playerDetails[playerDetails.count - 1].audioLinkUrl {
                keepCurrentEpisode(with: audioLink)
            }
        }
    }
    
    /// Replace new episode data on UI and in player.
    /// - Parameter ep: The episode index.
    func proceedToEpisode(ep: Int) {
        guard let audioLink = playerDetails[ep].audioLinkUrl,
              let epTitle = playerDetails[ep].epTitle,
              let epImage = playerDetails[ep].epImage else { return }
        audioPlayHelper.replaceCurrentItem(audioLink)
        self.epTitle.value = epTitle
        self.epImage.value = epImage
    }
    
    
    /// Keep current episode in player and pause the player.
    /// - Parameter audioLink: Audio url.
    func keepCurrentEpisode(with audioLink: String) {
        audioPlayHelper.replaceCurrentItem(audioLink)
        audioPlayHelper.pausePlayer()
    }
    
}

// MARK: - AudioPlayHelperDelegate

extension PlayerPageViewModel: AudioPlayHelperDelegate {
    
    func toggleButtonImage(_ audioPlayHelper: AudioPlayHelper, playerState: Int) {
        if playerState == 2 {
            self.playButtonType.value = .pause
        } else {
            self.playButtonType.value = .play
        }
    }
    
    func updateDuration(_ audioPlayHelper: AudioPlayHelper, duration: CMTime) {
        changeDuration(duration: duration)
        let time = audioPlayHelper.currentItemCurrentTime()
        changeProgress(currentTime: time, duration: duration)
    }
    
    func updateCurrentTime(_ audioPlayHelper: AudioPlayHelper, currentTime: CMTime) {
        changeCurrentTime(currentTime: currentTime)
        let itemDuration = audioPlayHelper.currentItemDuration()
        changeProgress(currentTime: currentTime, duration: itemDuration)
    }
    
    func didPlaybackEnd(_ audioPlayHelper: AudioPlayHelper) {
        print("didPlaybackEnd")
        proceedToNextItem()
    }
    
}
