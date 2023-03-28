//
//  AudioViewController.swift
//  Audio Recorder
//
//  Created by Shishir_Mac on 28/3/23.
//

import UIKit
import AVFoundation

class AudioViewController: UIViewController, AVAudioRecorderDelegate {
    
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var audioTableView: UITableView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var shareImageView: UIImageView!
    
    var recordingSession: AVAudioSession!
    var audioRecorder: AVAudioRecorder!
    var audioPlayer: AVAudioPlayer!
    
    
    var numberOfRercords: Int = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        if let number: Int = UserDefaults.standard.object(forKey: "MyNumber") as? Int {
            numberOfRercords = number
        }
        
        //setting session
        recordingSession = AVAudioSession.sharedInstance()
        
        //ask for permission
        AVAudioSession.sharedInstance().requestRecordPermission { (hasPermission) in
            if hasPermission {
                //accepted
            }
        }
    }
    
    // MARK: - Function
    func getDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentDirectory = paths[0]
        return documentDirectory
    }
    
    func displayAlert(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - IBAction
    @IBAction func playButtonAction(_ sender: UIButton) {
        //check if we have active recorder
        if audioRecorder == nil {
            numberOfRercords += 1
            let fileName = getDirectory().appendingPathComponent("\(numberOfRercords).m4a")
            
            let settings = [AVFormatIDKey: Int(kAudioFormatMPEG4AAC), AVSampleRateKey: 1200, AVNumberOfChannelsKey: 1, AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue]
            
            //start Audio Recording
            do {
                audioRecorder = try AVAudioRecorder(url: fileName, settings: settings)
                audioRecorder.delegate = self
                audioRecorder.record()
                playImageView.image = UIImage(named: "pause_button")
            } catch {
                displayAlert(title: "Oops!", message: "Recording Not Possible")
            }
        } else {
            audioRecorder.stop()
            UserDefaults.standard.set(numberOfRercords, forKey: "MyNumber")
            audioRecorder = nil
            
            audioTableView.reloadData()
            playImageView.image = UIImage(named: "play_button")
        }
    }
    
    @IBAction func shareButtonActon(_ sender: UIButton) {
        let activity = UIActivityViewController(activityItems: [audioPlayer as Any], applicationActivities: nil)
        activity.popoverPresentationController?.sourceView = self.view
        
        self.present(activity, animated: true, completion: nil)
    }
    
    
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension AudioViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfRercords
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = String(indexPath.row + 1)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("\(indexPath.row + 1).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            
        }
    }
}
