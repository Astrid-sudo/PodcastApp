//
//  PlayerPageViewModel.swift
//  PodcastApp
//
//  Created by Astrid on 2022/2/10.
//

import UIKit
import CoreMedia
import RxSwift

protocol PlayerPageViewModelType {
	var input: PlayerPageViewModelInput { get }
	var output: PlayerPageViewModelOutput { get }
}

protocol PlayerPageViewModelInput {
	func pausePlayer()
	func togglePlay()
	func switchToItem(_ switchType: SwitchItemType)
	func slideToTime(_ sliderValue: Double)
	func sliderTouchEnded(_ sliderValue: Double)
}

protocol PlayerPageViewModelOutput {
	var epTitle: Observable<String> { get }
	var epImageUrl: Observable<String> { get }
	var playButtonType: Observable<PlayButtonType> { get }
	var playProgress: Observable<Float> { get }
	var currentTime : Observable<String> { get }
	var duration : Observable<String> { get }
}

class PlayerPageViewModel: NSObject {
    
    // MARK: - properties be observed
    
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
	private func parsePlayerDetail() {
        guard playerDetails.count > currentEpisodeIndex else { return }
        let currentPlayerDetail = playerDetails[currentEpisodeIndex]
        guard let epTitle = currentPlayerDetail.epTitle,
              let epImageUrl = currentPlayerDetail.epImageUrl,
              let audioLinkUrl = currentPlayerDetail.audioLinkUrl else { return }
        
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
	private func changeCurrentTime(currentTime: CMTime) {
        guard !currentTime.isIndefinite else {
			self.currentTimeSubject.onNext("00:00:00")
            return
        }
        let currenTimeSeconds = Float(CMTimeGetSeconds(currentTime))
		self.currentTimeSubject.onNext(TimeCalculator.float(toTimecodeString: currenTimeSeconds))
    }
    
    /// Change duration.
    /// - Parameter duration: Current duration from audioPlayHelper.
	private func changeDuration(duration: CMTime) {
        guard !duration.isIndefinite else {
			self.durationSubject.onNext("00:00:00")
            return
        }
        let durationSeconds = Float(CMTimeGetSeconds(duration))
		self.durationSubject.onNext(TimeCalculator.float(toTimecodeString: durationSeconds))
    }
    
    /// Change play progress.
    /// - Parameter currentTime: Current currentTime from audioPlayHelper.
    /// - Parameter duration: Current duration from audioPlayHelper.
	private func changeProgress(currentTime: CMTime, duration: CMTime) {
        guard duration >= currentTime else { return }
        let currenTime = CMTimeGetSeconds(currentTime)
        let duration = CMTimeGetSeconds(duration)
		self.playProgressSubject.onNext(Float(currenTime / duration))
    }
    
    // MARK: - player method
    
    /// If current episode is not the last episode, proceed to play the next episode. If it is the last episode, then keep this episode in player.
    private func proceedToNextItem() {
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
	private func proceedToPreviousItem() {
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
	private func proceedToEpisode(ep: Int) {
        guard let audioLink = playerDetails[ep].audioLinkUrl,
              let epTitle = playerDetails[ep].epTitle,
              let epImageUrl = playerDetails[ep].epImageUrl else { return }
        audioPlayHelper.replaceCurrentItem(audioLink)
		self.epTitleSubject.onNext(epTitle)
		self.epImageUrlSubject.onNext(epImageUrl)

    }
    
    /// Keep current episode in player and pause the player.
    /// - Parameter audioLink: Audio url.
	private func keepCurrentEpisode(with audioLink: String) {
        audioPlayHelper.replaceCurrentItem(audioLink)
        audioPlayHelper.pausePlayer()
    }
    
}

// MARK: - AudioPlayHelperDelegate

extension PlayerPageViewModel: AudioPlayHelperDelegate {
    
    func toggleButtonImage(_ audioPlayHelper: AudioPlayHelper, playerState: Int) {
        if playerState == 2 {
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

// MARK: - PlayerPageViewModelType

extension PlayerPageViewModel: PlayerPageViewModelType {
	var input: PlayerPageViewModelInput { self }
	var output: PlayerPageViewModelOutput { self }
}

// MARK: - PlayerPageViewModelInput
extension PlayerPageViewModel: PlayerPageViewModelInput {

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

}

// MARK: - PlayerPageViewModelOutput
extension PlayerPageViewModel: PlayerPageViewModelOutput {
	var epTitle: Observable<String> { epTitleSubject.asObservable() }
	var epImageUrl: Observable<String> { epImageUrlSubject.asObservable() }
	var playButtonType: Observable<PlayButtonType> { playButtonTypeSubject.asObservable() }
	var playProgress: Observable<Float> { playProgressSubject.asObservable() }
	var currentTime : Observable<String> { currentTimeSubject.asObservable() }
	var duration : Observable<String> { durationSubject.asObservable() }
}


