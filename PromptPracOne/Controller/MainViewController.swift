//
//  MainViewController.swift
//  PromptPracOne
//
//  Created by 백현진 on 8/27/24.
//

import UIKit

class MainViewController: UIViewController, ScriptTableViewCellDelegate {
    @IBOutlet var mainView: MainView!
    
    let cellName = "ScriptTableViewCell"
    let cellReuseIdentifier = "ScriptTableViewCell"
    
    let addCellName = "AddScriptTableViewCell"
    let addCellReuseIdentifier = "AddScriptTableViewCell"
    
    let halfSizeTransitioningDelegate = HalfSizeTransitioningDelegate()
    
    var scripts: [(title: String, script: String, date: Date, isExpanded: Bool)] = [] // 스크립트 목록
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUI()
        initialLangugeButtonSetting()
        registerXib()
        // NotificationCenter에서 스크립트 추가 알림 수신 설정
        NotificationCenter.default.addObserver(self, selector: #selector(loadScripts), name: .didAddScript, object: nil)
        
        loadScripts() // 초기 스크립트 로드
    }
    
    func setUI() {
        mainView.backgroundColor = .black
        mainView.setTableViewUI()
        
        LanguageManager.shared.setLanguage(for: mainView.mainLabel, key: "allProject")
    }
    
    func registerXib() {
        let nibName = UINib(nibName: cellName, bundle: nil)
        mainView.scriptTableView.register(nibName, forCellReuseIdentifier: cellReuseIdentifier)
        
        mainView.scriptTableView.delegate = self
        mainView.scriptTableView.dataSource = self
        
        let nibName2 = UINib(nibName: addCellName, bundle: nil)
        mainView.scriptTableView.register(nibName2, forCellReuseIdentifier: addCellReuseIdentifier)
    }
    
    // UserDefaults에서 스크립트를 불러오고 날짜순으로 정렬하는 함수
    @objc func loadScripts() {
        let defaults = UserDefaults.standard
        let savedScripts = defaults.dictionary(forKey: "scripts") as? [String: [String: Any]] ?? [:]
        
        // 스크립트 배열 초기화
        scripts = savedScripts.compactMap { (key, value) in
            guard let script = value["script"] as? String,
                  let date = value["date"] as? Date else {
                return nil
            }
            return (title: key, script: script, date: date, isExpanded: false)
        }
        
        // 날짜를 기준으로 정렬 (오래된 날짜가 아래로)
        scripts.sort { $0.date > $1.date }
        mainView.scriptTableView.reloadData()
    }
    
    deinit {
        // ViewController가 메모리에서 해제될 때 Observer 제거
        NotificationCenter.default.removeObserver(self, name: .didAddScript, object: nil)
    }
    
    // 미리보기를 보여주는 함수
    func showScriptPreview(title: String, script: String) {
        // 미리보기용 뷰 설정
        let previewView = UIView(frame: CGRect(x: 0, y: 0, width: view.bounds.width - 40, height: 300))
        previewView.backgroundColor = CustomColor.darkModeDarkGrayColor.color
        previewView.layer.cornerRadius = 8
        previewView.layer.shadowColor = UIColor.black.cgColor
        previewView.layer.shadowOpacity = 0.5
        previewView.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        // 제목 라벨 설정
        let titleLabel = UILabel(frame: CGRect(x: 10, y: 10, width: previewView.bounds.width - 20, height: 30))
        titleLabel.text = title
        titleLabel.textColor = .white
        titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        titleLabel.textAlignment = .center
        previewView.addSubview(titleLabel)
        
        // 스크립트 내용 텍스트 뷰 설정
        let scriptTextView = UITextView(frame: CGRect(x: 10, y: 50, width: previewView.bounds.width - 20, height: 240))
        
        scriptTextView.textColor = .white
        scriptTextView.backgroundColor = .black
        scriptTextView.text = script
        scriptTextView.font = UIFont.systemFont(ofSize: 14)
        scriptTextView.isEditable = false
        scriptTextView.layer.cornerRadius = 8
        previewView.addSubview(scriptTextView)
        
        // 배경 뷰 설정
        let backgroundView = UIView(frame: view.bounds)
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        backgroundView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissPreview)))
        
        // 미리보기 뷰를 중앙에 배치
        previewView.center = backgroundView.center
        backgroundView.addSubview(previewView)
        
        // 배경 뷰를 메인 뷰에 추가
        view.addSubview(backgroundView)
    }
    
    // 미리보기 뷰를 닫는 함수
    @objc func dismissPreview(_ sender: UITapGestureRecognizer) {
        sender.view?.removeFromSuperview()
    }
    
    @IBAction func bluetoothButtonTapped(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let blueToothVC = storyboard.instantiateViewController(withIdentifier: "PeripheralViewController") as? PeripheralViewController {
            
            // RecordingViewController로 화면 전환
            navigationController?.pushViewController(blueToothVC, animated: true)
        }
    }
    
    func initialLangugeButtonSetting() {
        let currentLanguage = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as! String
        
        if currentLanguage == "ko" {
            mainView.languageButton.setTitle(" 한국어", for: .normal)
        } else {
            mainView.languageButton.setTitle(" English", for: .normal)
        }
    }
    
    @IBAction func languageButtonTapped(_ sender: UIButton) {
        let currentLanguage = UserDefaults.standard.array(forKey: "AppleLanguages")?.first as! String
        
        print(currentLanguage)
        
        if currentLanguage == "ko" {
            // 현재 언어가 한국어라면 영어로 전환
            UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()  // 설정을 즉시 적용
            mainView.languageButton.setTitle(" English", for: .normal)
        } else {
            // 그 외의 경우 (기본적으로 영어라면) 한국어로 전환
            UserDefaults.standard.set(["ko"], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()  // 설정을 즉시 적용

            mainView.languageButton.setTitle(" 한국어", for: .normal)
        }
        LanguageManager.shared.setLanguage(for: mainView.mainLabel, key: "allProject")
        
        mainView.scriptTableView.reloadData()
    }
    
    func restartApp() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        guard let delegate = windowScene.delegate as? SceneDelegate else { return }
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let rootViewController = storyboard.instantiateInitialViewController()
        
        delegate.window?.rootViewController = rootViewController
        delegate.window?.makeKeyAndVisible()
        
        UIView.transition(with: delegate.window!, duration: 0.5, options: .transitionCrossDissolve, animations: {}, completion: nil)
    }
    
    @IBAction func infoButtonTapped(_ sender: UIButton) {
        guard let vc = self.storyboard?.instantiateViewController(withIdentifier: "InfoViewController") as? InfoViewController else { return }
        
        vc.modalPresentationStyle = .overFullScreen
        self.present(vc, animated: true)
    }
    
    
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let count = scripts.count
        
        return count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row < scripts.count {
            guard let cell = mainView.scriptTableView.dequeueReusableCell(withIdentifier: cellReuseIdentifier, for: indexPath) as? ScriptTableViewCell else { return UITableViewCell()}
            
            let scriptData = scripts[indexPath.row]
            
            cell.titleLabel.text = "\(scriptData.title)"
            cell.isExpanded = scriptData.isExpanded
            cell.indexPath = indexPath
            cell.delegate = self
            
            return cell
        } else {
            guard let cell = mainView.scriptTableView.dequeueReusableCell(withIdentifier: addCellReuseIdentifier, for: indexPath) as? AddScriptTableViewCell else { return UITableViewCell()}
            
            LanguageManager.shared.setLanguage(for: cell.addLabel, key: "addProject")
            
            return cell
        }
        
    }
    
    // 테이블 뷰의 셀에 대한 스와이프 작업 설정
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let previewText = LanguageManager.shared.setLanguageText(key: "preview")
        let deleteText = LanguageManager.shared.setLanguageText(key: "delete")
        let cancelText = LanguageManager.shared.setLanguageText(key: "cancel")
        let deleteOKText = LanguageManager.shared.setLanguageText(key: "deleteOk")
        
        let thisScriptDeleteText =
        LanguageManager.shared.setLanguageText(key: "thisScriptDelete")
        
        let deleteCompleteText =
        LanguageManager.shared.setLanguageText(key: "deleteComplete")
        
        let checkText = LanguageManager.shared.setLanguageText(key: "check")
        
        if indexPath.row < scripts.count {
            let script = scripts[indexPath.row]
            // 미리보기 액션
            let previewAction = UIContextualAction(style: .normal, title: previewText) { action, view, completionHandler in
                
                self.showScriptPreview(title: script.title, script: script.script)
                completionHandler(true) // 액션이 완료되었음을 알림
            }
            previewAction.backgroundColor = .clear // 미리보기 버튼의 배경색 설정
            
            
            // 삭제 액션
            let deleteAction = UIContextualAction(style: .destructive, title: deleteText) { action, view, completionHandler in
                let alert = UIAlertController(title: deleteOKText, message: thisScriptDeleteText, preferredStyle: .alert)
                
                let confirmDeleteAction = UIAlertAction(title: deleteText, style: .destructive) { _ in
                    self.scripts.remove(at: indexPath.row)
                    
                    var savedScripts = UserDefaults.standard.dictionary(forKey: "scripts") as? [String: [String: Any]] ?? [:]
                    savedScripts.removeValue(forKey: script.title)
                    UserDefaults.standard.set(savedScripts, forKey: "scripts")
                    
                    tableView.reloadData()
                    
                    let successAlert = UIAlertController(title: nil, message: deleteCompleteText, preferredStyle: .alert)
                    successAlert.addAction(UIAlertAction(title: checkText, style: .default, handler: nil))
                    self.present(successAlert, animated: true, completion: nil)
                }
                
                let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
                alert.addAction(confirmDeleteAction)
                alert.addAction(cancelAction)
                
                self.present(alert, animated: true, completion: nil)
                completionHandler(true) // 액션이 완료되었음을 알림
            }
            
            // 액션들을 UISwipeActionsConfiguration에 추가
            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, previewAction])
            configuration.performsFirstActionWithFullSwipe = false // 전체 스와이프 시 첫 번째 액션 실행 방지
            
            return configuration
        } else {
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if indexPath.row < scripts.count {
            
            tableView.deselectRow(at: indexPath, animated: true)
            
            scripts[indexPath.row].isExpanded.toggle()
            
            // 선택된 셀만 높이를 애니메이션과 함께 업데이트
            tableView.beginUpdates()
            tableView.reloadRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
        } else {
            guard let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "UpdateScriptViewController") as? UpdateScriptViewController else { return }
            
            //vc.modalPresentationStyle =
            present(vc, animated: true)
        }
    }
    
    func didTapScriptButton(at indexPath: IndexPath) {
        let script = scripts[indexPath.row]
        self.showScriptPreview(title: script.title, script: script.script)
    }
    
    func didTapRecordButton(at indexPath: IndexPath) {
        let scriptData = scripts[indexPath.row]
        // 스토리보드에서 RecordingViewController를 인스턴스화
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let recordingVC = storyboard.instantiateViewController(withIdentifier: "RecordingViewController") as? RecordingViewController {
            recordingVC.recordingManager.scriptText = scriptData.script // 선택된 스크립트 전달
            
            // 클로저 설정: recordingVC에 데이터가 전달된 후 실행할 메서드 정의
            recordingVC.onScriptReceived = {
                recordingVC.setAllIn()
            }
            
            // RecordingViewController로 화면 전환
            navigationController?.pushViewController(recordingVC, animated: true)
        }
    }
    
    func didTapTrashButton(at indexPath: IndexPath) {
        let deleteText = LanguageManager.shared.setLanguageText(key: "delete")
        let cancelText = LanguageManager.shared.setLanguageText(key: "cancel")
        let deleteOKText = LanguageManager.shared.setLanguageText(key: "deleteOk")
        
        let thisScriptDeleteText =
        LanguageManager.shared.setLanguageText(key: "thisScriptDelete")
        
        let deleteCompleteText =
        LanguageManager.shared.setLanguageText(key: "deleteComplete")
        
        let checkText = LanguageManager.shared.setLanguageText(key: "check")
        
        let script = scripts[indexPath.row]
        
        let alert = UIAlertController(title: deleteOKText, message: thisScriptDeleteText, preferredStyle: .alert)
        
        let confirmDeleteAction = UIAlertAction(title: deleteText, style: .destructive) { _ in
            self.scripts.remove(at: indexPath.row)
            
            var savedScripts = UserDefaults.standard.dictionary(forKey: "scripts") as? [String: [String: Any]] ?? [:]
            savedScripts.removeValue(forKey: script.title)
            UserDefaults.standard.set(savedScripts, forKey: "scripts")
            
            self.mainView.scriptTableView.reloadData()
            
            let successAlert = UIAlertController(title: nil, message: deleteCompleteText, preferredStyle: .alert)
            successAlert.addAction(UIAlertAction(title: checkText, style: .default, handler: nil))
            self.present(successAlert, animated: true, completion: nil)
        }
        
        let cancelAction = UIAlertAction(title: cancelText, style: .cancel, handler: nil)
        alert.addAction(confirmDeleteAction)
        alert.addAction(cancelAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    
}
