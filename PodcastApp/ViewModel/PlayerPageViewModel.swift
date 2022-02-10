//
//  PlayerPageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import CoreMedia

class PlayerPageViewModel {
    
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
    
    private lazy var audioPlayer: AudioPlayer = {
        let audioPlayer = AudioPlayer()
        audioPlayer.delegate = self
        return audioPlayer
    }()
    
    // MARK: - init / deinit
    
    init(playerDetails: [PlayerDetail], currentEpisodeIndex: Int) {
        self.playerDetails = playerDetails
        self.currentEpisodeIndex = currentEpisodeIndex
        parsePlayerDetail()
        configPlayer()
    }
    
    init() {}
    
    deinit {
        audioPlayer.releasePlayer()
        print("PlayerPageModel Deinit")
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
        audioPlayer.configQueuePlayer(audioLinkUrl)
    }
    
    func changeCurrentTime(currentTime: CMTime) {
        let currenTimeSeconds = CMTimeGetSeconds(currentTime)
        self.currentTime.value = TimeManager.floatToTimecodeString(seconds: Float(currenTimeSeconds)) + " /"
    }
    
    func changeDuration(duration: CMTime) {
        let durationSeconds = CMTimeGetSeconds(duration)
        self.duration.value = TimeManager.floatToTimecodeString(seconds: Float(durationSeconds))
    }
    
    func changeProgress(currentTime: CMTime, duration: CMTime) {
        guard duration >= currentTime else { return }
        let currenTime = CMTimeGetSeconds(currentTime)
        let duration = CMTimeGetSeconds(duration)
        self.playProgress.value = Float(currenTime / duration)
    }
    
    // MARK: - player method
    
    func togglePlay() {
        audioPlayer.togglePlay()
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
        audioPlayer.slideToTime(sliderValue)
    }
    
    func sliderTouchEnded(_ sliderValue: Double) {
        audioPlayer.sliderTouchEnded(sliderValue)
    }
    
    func pausePlayer() {
        audioPlayer.pausePlayer()
    }
    
}

// MARK: - AudioPlayerProtocol

extension PlayerPageViewModel: AudioPlayerProtocol {
    
    func updateDuration(_ audioPlayer: AudioPlayer, duration: CMTime) {
        changeDuration(duration: duration)
        if let currentTime = audioPlayer.currentItemCurrentTime {
            changeProgress(currentTime: currentTime, duration: duration)
        }
    }
    
    func updateCurrentTime(_ audioPlayer: AudioPlayer, currentTime: CMTime) {
        changeCurrentTime(currentTime: currentTime)
        if let duration = audioPlayer.currentItemDuration {
            changeProgress(currentTime: currentTime, duration: duration)
        }
    }
    
    func didPlaybackEnd(_ audioPlayer: AudioPlayer) {
        print("didPlaybackEnd")
        proceedToNextItem()
    }
    
    func togglePlayButtonImage(_ audioPlayer: AudioPlayer, playButtonType: PlayButtonType) {
        self.playButtonType.value = playButtonType
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
        audioPlayer.replaceCurrentItem(with: audioLink)
        self.epTitle.value = epTitle
        self.epImage.value = epImage
    }
    
    func keepCurrentEpisode(with audioLink: String) {
        audioPlayer.replaceCurrentItem(with: audioLink)
        audioPlayer.pausePlayer()
    }
    
}

