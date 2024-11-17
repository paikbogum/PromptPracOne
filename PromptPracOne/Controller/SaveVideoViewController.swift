//
//  SaveVideoViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/31/24.
//

import UIKit
import Photos
import AVFoundation
import GoogleMobileAds
import SwiftRater

class SaveVideoViewController: UIViewController, GADFullScreenContentDelegate {
    @IBOutlet var saveView: SaveView!
    
    var videoModel: VideoModel?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isPlaying = false // 현재 재생 상태를 추적
    private var rewardedInterstitialAd: GADRewardedInterstitialAd?
    
    private var hideButtonTimer: Timer?
    
    let singletonMan = LanguageManager.shared
    
    let lanA = LanguageManager.shared.setLanguageText(key: "failSave")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveView.setButtonUI()
        setupVideoPlayer()
        setupEndNotification()
        setupTimeObserver()
        loadRewardedInterstitialAd() // 보상형 전면광고
        addTapGestureRecognizer()
        //setupTapGesture() // 탭 제스처 설정
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        playerLayer?.frame = saveView.videoContainerView.bounds
    }
    
    
    private func setupVideoPlayer() {
        guard let videoURL = videoModel?.videoURL else { return }
        
        // AVPlayer 초기화 및 AVPlayerLayer 설정
        player = AVPlayer(url: videoURL)
        playerLayer = AVPlayerLayer(player: player)
        
        guard let playerLayer = playerLayer else { return }
        playerLayer.frame = saveView.videoContainerView.bounds
        playerLayer.videoGravity = .resizeAspectFill
         
        // 좌우 반전 적용
        playerLayer.setAffineTransform(CGAffineTransform(scaleX: -1.0, y: 1.0))
        
        saveView.videoContainerView.layer.addSublayer(playerLayer)
        
        saveView.progressBar.value = 0.0
    }
    
    private func setupTimeObserver() {
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            guard let self = self, let currentItem = self.player?.currentItem else { return }
            let currentTime = CMTimeGetSeconds(time)
            let duration = CMTimeGetSeconds(currentItem.duration)
            
            if duration.isFinite {
                saveView.progressBar.value = Float(currentTime / duration)
                saveView.currentTimeLabel.text = self.formatTime(seconds: currentTime)
                saveView.remainTimeLabel.text = self.formatTime(seconds: duration - currentTime)
            }
        }
    }

    @IBAction func progressBarValueChanged(_ sender: UISlider) {
        guard let duration = player?.currentItem?.duration else { return }
        let totalSeconds = CMTimeGetSeconds(duration)
        let value = Float64(sender.value) * totalSeconds
        let seekTime = CMTime(seconds: value, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.seek(to: seekTime)
        
        // Update labels manually after seeking
        saveView.currentTimeLabel.text = formatTime(seconds: value)
        saveView.remainTimeLabel.text = formatTime(seconds: totalSeconds - value)
    }
    
    deinit {
        player?.pause()
        player = nil
        hideButtonTimer?.invalidate()
    }
    
    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            saveView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
            showPlayButton()
        } else {
            saveView.currentTimeLabel.isHidden = false
            player?.play()
            saveView.playPauseButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
            
            showPlayButton() // 버튼을 다시 표시
            hidePlayButton(after: 3.0) // 3초 후에 버튼 숨기기
        }
        isPlaying.toggle()
    }
    
    private func showPlayButton() {
        hideButtonTimer?.invalidate() // 기존 타이머 취소
        UIView.animate(withDuration: 0.3) {
            self.saveView.playPauseButton.alpha = 1.0
        }
        hidePlayButton(after: 3.0) // 3초 후 숨기기
    }
    
    private func hidePlayButton(after delay: TimeInterval) {
        hideButtonTimer?.invalidate() // 기존 타이머 취소
        hideButtonTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false) { [weak self] _ in
            UIView.animate(withDuration: 0.3) {
                self?.saveView.playPauseButton.alpha = 0.0
            }
        }
    }
    
    private func addTapGestureRecognizer() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleScreenTap))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func handleScreenTap() {
        if saveView.playPauseButton.alpha == 0 {
            showPlayButton()
        }
    }

    private func setupEndNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(videoDidEnd), name: .AVPlayerItemDidPlayToEndTime, object: player?.currentItem)
    }
    
    @objc private func videoDidEnd() {
        player?.seek(to: .zero) // 비디오 재생 시간을 처음으로 되돌립니다.
        saveView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal) // 버튼 텍스트를 "재생"으로 변경
        isPlaying = false
        saveView.currentTimeLabel.isHidden = true
    }
    
    // 광고 메서드
    func loadRewardedInterstitialAd() {
        //let adUnitID = "ca-app-pub-3940256099942544/6978759866" // 테스트 광고 ID
        
        // 애드몹에서 생성한 광고 단위ID
        let adUnitID = "ca-app-pub-6249716395928500/6258053138" //진짜 ID
        GADRewardedInterstitialAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error = error {
                print("Failed to load rewarded interstitial ad: \(error.localizedDescription)")
                return
            }
            self.rewardedInterstitialAd = ad
            self.rewardedInterstitialAd?.fullScreenContentDelegate = self
            print("Rewarded interstitial ad loaded.")
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        //광고 메서드
        if let ad = rewardedInterstitialAd {
            ad.present(fromRootViewController: self) {
                // 광고를 끝까지 시청했을 때 실행되는 코드
                print("광고 끝")
                self.saveVideoToGallery()
            }
        } else {
            print("Rewarded ad wasn't ready, saving video directly.")
            // 광고가 준비되지 않은 경우 바로 비디오 저장
            saveVideoToGallery()
        }
    }
    
    func saveVideoToGallery() {
        guard let videoURL = videoModel?.videoURL else { return }
        
        // 갤러리에 비디오 저장
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: videoURL)
        }) { success, error in
            DispatchQueue.main.async {
                if success {
                    let alert = UIAlertController(title: self.singletonMan.setLanguageText(key: "alertSaveComplete"), message: self.singletonMan.setLanguageText(key: "completeSaveToGallery"), preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: self.singletonMan.setLanguageText(key: "check"), style: .default, handler: { _ in
                        self.dismiss(animated: true, completion: nil) // 저장 후 화면을 닫습니다.
                        
                        //인앱 리뷰 팝업 띄우기
                        SwiftRater.check()
                     
                    }))
                    self.present(alert, animated: true, completion: nil)
                } else if let error = error {
                    let alert = UIAlertController(title: self.singletonMan.setLanguageText(key: "alertFailSaveComplete"), message: "\(self.lanA) \(error.localizedDescription)", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: self.singletonMan.setLanguageText(key: "check"), style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: UIButton) {
        // RecordViewController로 돌아가기
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause() // 뷰가 사라질 때 비디오 재생을 멈춤
    }
    
    /*
    private func setupTimeObserver() {
        // 1초마다 현재 재생 시간을 업데이트
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.saveView.currentTimeLabel.text = self?.formatTime(seconds: seconds)
        }
    }*/
    
    private func formatTime(seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // 광고메서드
    
    // GADFullScreenContentDelegate 메서드
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadRewardedInterstitialAd() // 새로운 광고를 로드
        self.saveVideoToGallery()
    }
}
