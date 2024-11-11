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

class SaveVideoViewController: UIViewController, GADFullScreenContentDelegate {
    @IBOutlet var saveView: SaveView!
    
    var videoModel: VideoModel?
    private var player: AVPlayer?
    private var playerLayer: AVPlayerLayer?
    private var isPlaying = false // 현재 재생 상태를 추적
    private var rewardedAd: GADRewardedAd?
    
    let singletonMan = LanguageManager.shared
    
    let lanA = LanguageManager.shared.setLanguageText(key: "failSave")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        saveView.setButtonUI()
        setupVideoPlayer()
        setupEndNotification()
        setupTimeObserver()
        loadRewardedAd() // 다음 버전에 활성화
        //setupTapGesture() // 탭 제스처 설정
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
        
        // 비디오 초기 상태는 일시 정지
        player?.pause()
        isPlaying = false
    }

    @IBAction func playPauseButtonTapped(_ sender: UIButton) {
        if isPlaying {
            player?.pause()
            saveView.playPauseButton.setImage(UIImage(systemName: "play.fill"), for: .normal)
        } else {
            saveView.currentTimeLabel.isHidden = false
            player?.play()
            saveView.playPauseButton.setImage(UIImage(systemName: "stop.fill"), for: .normal)
        }
        isPlaying.toggle()
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
    func loadRewardedAd() {
        //test id
        //let adUnitID = "ca-app-pub-3940256099942544/1712485313"
        
        // 애드몹에서 생성한 광고 단위ID
        let adUnitID = "ca-app-pub-6249716395928500/6491664492"

        GADRewardedAd.load(withAdUnitID: adUnitID, request: GADRequest()) { ad, error in
            if let error = error {
                print("Failed to load rewarded ad with error: \(error.localizedDescription)")
                return
            }
            self.rewardedAd = ad
            self.rewardedAd?.fullScreenContentDelegate = self
        }
    }
    
    @IBAction func saveButtonTapped(_ sender: UIButton) {
        //광고 메서드
        if let ad = rewardedAd {
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
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // 레이아웃 변경에 따라 플레이어 레이어 크기 업데이트
        playerLayer?.frame = saveView.videoContainerView.bounds
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player?.pause() // 뷰가 사라질 때 비디오 재생을 멈춤
    }
    
    private func setupTimeObserver() {
        // 1초마다 현재 재생 시간을 업데이트
        let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player?.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { [weak self] time in
            let seconds = CMTimeGetSeconds(time)
            self?.saveView.currentTimeLabel.text = self?.formatTime(seconds: seconds)
        }
    }
    
    private func formatTime(seconds: Double) -> String {
        let mins = Int(seconds) / 60
        let secs = Int(seconds) % 60
        return String(format: "%02d:%02d", mins, secs)
    }
    
    // 광고메서드
    
    // GADFullScreenContentDelegate 메서드
    func adDidDismissFullScreenContent(_ ad: GADFullScreenPresentingAd) {
        loadRewardedAd() // 새로운 광고를 로드
        self.saveVideoToGallery()
    }
}
