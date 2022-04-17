//
//  PlayerPageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import CoreMedia
import RxSwift

class PlayerPageViewModel: NSObject {
    
    // MARK: - properties be observed
    
//    let epTitle: Box<String> = Box("")
//    let epImageUrl: Box<String> = Box(String())
//    let playButtonType: Box<PlayButtonType> = Box(.play)
//    let playProgress: Box<Float> = Box(.zero)
//    let currentTime = Box("00:00:00")
//    let duration = Box("00:00:00")

	var epTitle: Observable<String> {
		return epTitleSubject.asObservable()
	}

	var epImageUrl: Observable<String> {
		return epImageUrlSubject.asObservable()
	}

	var playButtonType: Observable<PlayButtonType> {
		return playButtonTypeSubject.asObservable()
	}

	var playProgress: Observable<Float> {
		return playProgressSubject.asObservable()
	}

	var currentTime : Observable<String> {
		currentTimeSubject.asObservable()
	}

	var duration : Observable<String> {
		durationSubject.asObservable()
	}

	private let epTitleSubject = BehaviorSubject<String>(value: "")
	private let epImageUrlSubject =  BehaviorSubject<String>(value: "")
	private let playButtonTypeSubject = BehaviorSubject<PlayButtonType>(value: .play)
	private let playProgressSubject = PublishSubject<Float>()
	private let currentTimeSubject = BehaviorSubject<String>(value: "00:00:00")
	private let durationSubject = BehaviorSubject<String>(value: "00:00:00")

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
              let epImageUrl = currentPlayerDetail.epImageUrl,
              let audioLinkUrl = currentPlayerDetail.audioLinkUrl else { return }
        
//        self.epTitle.value = epTitle
//        self.epImageUrl.value = epImageUrl
		self.epTitleSubject.onNext(epTitle)
		self.epImageUrlSubject.onNext(epImageUrl)
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
        guard !currentTime.isIndefinite else {
//            self.currentTime.value = "00:00:00"
			self.currentTimeSubject.onNext("00:00:00")
            return
        }
        let currenTimeSeconds = Float(CMTimeGetSeconds(currentTime))
//        self.currentTime.value = TimeCalculator.float(toTimecodeString: currenTimeSeconds)
		self.currentTimeSubject.onNext(TimeCalculator.float(toTimecodeString: currenTimeSeconds))
    }
    
    /// Change duration.
    /// - Parameter duration: Current duration from audioPlayHelper.
    func changeDuration(duration: CMTime) {
        guard !duration.isIndefinite else {
//            self.duration.value = "00:00:00"
			self.durationSubject.onNext("00:00:00")
            return
        }
        let durationSeconds = Float(CMTimeGetSeconds(duration))
//        self.duration.value = TimeCalculator.float(toTimecodeString: durationSeconds)
		self.durationSubject.onNext(TimeCalculator.float(toTimecodeString: durationSeconds))
    }
    
    /// Change play progress.
    /// - Parameter currentTime: Current currentTime from audioPlayHelper.
    /// - Parameter duration: Current duration from audioPlayHelper.
    func changeProgress(currentTime: CMTime, duration: CMTime) {
        guard duration >= currentTime else { return }
        let currenTime = CMTimeGetSeconds(currentTime)
        let duration = CMTimeGetSeconds(duration)
//        self.playProgress.value = Float(currenTime / duration)
		self.playProgressSubject.onNext(Float(currenTime / duration))
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
    
    /// Ask audioPlayHelper slide to time according to progress bar value during value change.
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
//        currentTime.value = "00:00:00"
		currentTimeSubject.onNext("00:00:00")
        if currentEpisodeIndex > 0 {
            currentEpisodeIndex -= 1
            proceedToEpisode(ep: currentEpisodeIndex)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.audioPlayHelper.playPlayer()
            }
        } else {
            if let audioLink = playerDetails[0].audioLinkUrl {
                keepCurrentEpisode(with: audioLink)
            }
        }
    }
    
    /// If current episode is not the first episode, proceed to play the previous episode. If it is the first episode, then keep this episode in player.
    func proceedToPreviousItem() {
//        currentTime.value = "00:00:00"
		currentTimeSubject.onNext("00:00:00")
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
              let epImageUrl = playerDetails[ep].epImageUrl else { return }
        audioPlayHelper.replaceCurrentItem(audioLink)
//        self.epTitle.value = epTitle
//        self.epImageUrl.value = epImageUrl
		self.epTitleSubject.onNext(epTitle)
		self.epImageUrlSubject.onNext(epImageUrl)

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
//            self.playButtonType.value = .pause
			self.playButtonTypeSubject.onNext(.pause)
        } else {
            self.playButtonTypeSubject.onNext(.play)
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
