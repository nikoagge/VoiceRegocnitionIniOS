//
//  HomeViewController.swift
//  VoiceRecognitionIniOS
//
//  Created by Nikolas Aggelidis on 20/11/20.
//

import UIKit
import Speech

class HomeViewController: UIViewController {
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var speechLabel: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    let audioEngine = AVAudioEngine()
    let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "el-GR "))
    let request = SFSpeechAudioBufferRecognitionRequest()
    var task: SFSpeechRecognitionTask!
    var isStart = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        debugPrint(SFSpeechRecognizer.supportedLocales())
        colorView.layer.cornerRadius = 10
        requestPermission()
    }
    
    @IBAction func startButtonTouchUpInside(_ sender: UIButton) {
        
        self.speechLabel.becomeFirstResponder()

        isStart = !isStart
        
        if isStart {
            startSpeechRecognition()
            startButton.setTitle("STOP", for: .normal)
            startButton.backgroundColor = .systemGreen
        } else {
            cancelSpeechRecognition()
            startButton.setTitle("START", for: .normal)
            startButton.backgroundColor = .systemOrange
        }
    }
    
    private func requestPermission() {
        startButton.isEnabled = false
        SFSpeechRecognizer.requestAuthorization { (authState) in
            OperationQueue.main.addOperation {
                if authState == .authorized {
                    self.startButton.isEnabled = true
                } else if authState == .denied {
                    self.displayAlertController(with: "User denied permission.")
                } else if authState == .notDetermined {
                    self.displayAlertController(with: "In user's iPhone there is no speech recognition.")
                } else if authState == .restricted {
                    self.displayAlertController(with: "User has been restricted for using the speech recognition.")
                }
            }
        }
    }
    
    private func startSpeechRecognition() {
        let node = audioEngine.inputNode
        let recordingFormat = node.outputFormat(forBus: 0)
        node.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, _) in
            self.request.append(buffer)
        }
        
        audioEngine.prepare()
        do {
            try audioEngine.start()
        } catch let error {
            self.displayAlertController(with: "Error comes here for starting the audio listener: \(error.localizedDescription).")
        }
        
        guard let speechRecognizer = SFSpeechRecognizer() else {
            self.displayAlertController(with: "Recognition is not allowed on your local.")
            return }
        
        if !speechRecognizer.isAvailable {
            self.displayAlertController(with: "Recognition is free right now. Please try again after some time.")
        }
        
        task = speechRecognizer.recognitionTask(with: request, resultHandler: { (response, error) in
            guard let response = response else {
                if error != nil {
                    self.displayAlertController(with: error.debugDescription)
                } else {
                    self.displayAlertController(with: "Problem in giving the response.")
                }
                
                return
            }
            
            let message = response.bestTranscription.formattedString
            self.speechLabel.text = message
            
            var lastString: String = ""
            for segment in response.bestTranscription.segments {
                let indexTo = message.index(message.startIndex, offsetBy: segment.substringRange.location)
                lastString = String(message[indexTo...])
            }
            
            if lastString == "red" {
                self.view.backgroundColor = .systemRed
            } else if lastString.elementsEqual("green") {
                self.view.backgroundColor = .systemGreen
            } else if lastString.elementsEqual("yellow") {
                self.view.backgroundColor = .systemYellow
            } else if lastString.elementsEqual("blue") {
                self.view.backgroundColor = .systemBlue
            } else if lastString.elementsEqual("black") {
                self.view.backgroundColor = .black
            }
        })
    }
    
    func cancelSpeechRecognition() {
        task.finish()
        task.cancel()
        task = nil
        
        request.endAudio()
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
    }
}
