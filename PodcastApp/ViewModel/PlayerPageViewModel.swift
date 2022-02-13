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
    
    private func configPlayer() {
        guard let audioLinkUrl = playerDetails[currentEpisodeIndex].audioLinkUrl else { return }
        audioPlayHelper.configPlayer(audioLinkUrl)
    }
    
    func changeCurrentTime(currentTime: CMTime) {
        let currenTimeSeconds = Float(CMTimeGetSeconds(currentTime))
        self.currentTime.value = TimeCalculator.float(toTimecodeString: currenTimeSeconds)
    }
    
    func changeDuration(duration: CMTime) {
        let durationSeconds = Float(CMTimeGetSeconds(duration))
        self.duration.value = TimeCalculator.float(toTimecodeString: durationSeconds)
    }
    
    func changeProgress(currentTime: CMTime, duration: CMTime) {
        guard duration >= currentTime else { return }
        let currenTime = CMTimeGetSeconds(currentTime)
        let duration = CMTimeGetSeconds(duration)
        self.playProgress.value = Float(currenTime / duration)
    }
    
    // MARK: - player method
    
    func togglePlay() {
        audioPlayHelper.togglePlay()
    }
    
    func switchToItem(_ switchType: SwitchItemType) {
        switch switchType {
        case .next:
            proceedToNextItem()
        case .previous:
            proceedToPreviousItem()
        }
    }
    
    func slideToTime(_ sliderValue: Double) {
        audioPlayHelper.slide(toTime: sliderValue)
    }
    
    func sliderTouchEnded(_ sliderValue: Double) {
        audioPlayHelper.sliderTouchEnded(sliderValue)
    }
    
    func pausePlayer() {
        audioPlayHelper.pausePlayer()
    }
    
}

// MARK: - AudioPlayHelperDelegate

extension PlayerPageViewModel: AudioPlayHelperDelegate {
    
    func toggleButtonImage(_ audioPlayHelper: AudioPlayHelper, playerState: String) {
        if playerState == "play" {
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
    
    func proceedToNextItem() {
        if currentEpisodeIndex > 0 {
            currentEpisodeIndex -= 1
            proceedToEpisode(ep: currentEpisodeIndex)
        } else {
            if let audioLink = playerDetails[0].audioLinkUrl {
                keepCurrentEpisode(with: audioLink)
            }
        }
    }
    
    func proceedToPreviousItem() {
        if playerDetails.count - 1 > currentEpisodeIndex {
            currentEpisodeIndex += 1
            proceedToEpisode(ep: currentEpisodeIndex)
        } else {
            if let audioLink = playerDetails[playerDetails.count - 1].audioLinkUrl {
                keepCurrentEpisode(with: audioLink)
            }
        }
    }
    
    func proceedToEpisode(ep: Int) {
        guard let audioLink = playerDetails[ep].audioLinkUrl,
              let epTitle = playerDetails[ep].epTitle,
              let epImage = playerDetails[ep].epImage else { return }
        audioPlayHelper.replaceCurrentItem(audioLink)
        self.epTitle.value = epTitle
        self.epImage.value = epImage
    }
    
    func keepCurrentEpisode(with audioLink: String) {
        audioPlayHelper.replaceCurrentItem(audioLink)
        audioPlayHelper.pausePlayer()
    }
    
}

