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
    
    private let cellIdentifier: String = "audioCell"
    
    var numberOfRercords: Int = 0
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        audioTableView.delegate = self
        audioTableView.dataSource = self
        
        self.audioTableView.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: cellIdentifier)
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
    
    @objc func shareButtonTapped(_ sender: UIButton) {
        // get the index path of the cell containing the tapped button
        guard let cell = sender.superview?.superview as? AudioTableViewCell,
              let indexPath = audioTableView.indexPath(for: cell) else {
                  return
              }
        
        // get the URL of the recording file
        let fileURL = getDirectory().appendingPathComponent("recording \(indexPath.row + 1).m4a")
        
        // create the activity view controller and set up the items to share
        let activityViewController = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = sender
        present(activityViewController, animated: true, completion: nil)
    }
    
    
    // MARK: - IBAction
    @IBAction func playButtonAction(_ sender: UIButton) {
        //check if we have active recorder
        if audioRecorder == nil {
            numberOfRercords += 1
            let fileName = getDirectory().appendingPathComponent("recording \(numberOfRercords).m4a")
            
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
        let activity = UIActivityViewController(activityItems: [audioPlayer!], applicationActivities: nil)
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
        if let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as? AudioTableViewCell {
            cell.titleLabel.text = "recording " + String(indexPath.row + 1) + ".m4a"
            
            cell.shareButton.addTarget(self, action: #selector(shareButtonTapped(_:)), for: .touchUpInside)
            return cell
        }
        return UITableViewCell()
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("recording \(indexPath.row + 1).m4a")
        
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: path)
            audioPlayer.play()
        } catch {
            displayAlert(title: "OOPS", message: "Recorder failed")
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        let path = getDirectory().appendingPathComponent("recording \(indexPath.row + 1).m4a")
        
        if editingStyle == .delete {
            do {
                if FileManager.default.fileExists(atPath: path.path) {
                    try FileManager.default.removeItem(at: path)
                    numberOfRercords -= 1
                    audioTableView.deleteRows(at: [indexPath], with: .automatic)
                    UserDefaults.standard.set(numberOfRercords, forKey: "MyNumber")
                    audioTableView.reloadData()
                } else {
                    displayAlert(title: "OOPS", message: "File not found")
                }
            } catch {
                displayAlert(title: "OOPS", message: "Delete failed")
                print(error.localizedDescription)
            }
        }
    }
}
