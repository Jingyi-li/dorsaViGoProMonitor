//
//  ViewController.swift
//  dorsaViGoProMonitor
//
//  Created by dorsaVi Hardware on 10/9/18.
//  Copyright © 2018 dorsaVi Hardware. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import Alamofire
import SwiftyJSON
import IJKMediaFramework

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var uiTextFieldSource: UITextField!
    @IBOutlet weak var uiButtonStartStreaming: UIButton!
    @IBOutlet weak var uiViewPreview: UIView!
    @IBOutlet weak var mediaList: UITableView!
    @IBOutlet weak var uiTextFieldStreamRate: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var localList: UITableView!
    
    var nameArray = [String]()
    var localNameArray = [String]()
    var directory: String?
    var selectedName: Int?
    var udpTimer: Timer!
    var flagRecord: Bool?
    var playerIJK : IJKFFMoviePlayerController?
    var playerViewController = AVPlayerViewController()
    var flag = ["livePlay": false, "goproPlay": false]
    var player = AVPlayer()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mediaList.delegate = self
        mediaList.dataSource = self
//        mediaList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        mediaList.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        localList.delegate = self
        localList.dataSource = self
        localList.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableViewCell")
        // Do any additional setup after loading the view, typically from a nib.
        uiTextFieldStreamRate.text = "1000000"
        flagRecord = false
        setRecordButtonView(flagRecord!)
        playerIJK = initLiveStream()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func uiButtonStartStreamingOnPressed(_ sender: Any) {
        var videoURLInput: String!
        videoURLInput = uiTextFieldSource.text
//        videoURLInput = "http://10.5.5.9:8080/Videos/DCIM/100GOPRO/GOPR1306.MP4"
        playVideo(url: videoURLInput)
        
    }
    @IBAction func liveStreamButton(_ sender: Any) {
        self.udpTimer?.invalidate()
        let streamRate = Int(uiTextFieldStreamRate.text ?? "70000")
        self.setStreamingRate(streamRate: streamRate!)
        
        //-- GoPro command controller usage
        let goproCommandController = GoProCommandController.controller
        let goproLiveStreamUrl = goproCommandController.GoProStartStreaming()
        //-- Alamofire: make http request
        //-- reference: https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#http-methods
        // without response handling (default: .GET method)
        // Alamofire.request(goproLiveStreamUrl)
        // with response handling (json Serializer)
        Alamofire.request(goproLiveStreamUrl).responseJSON { response in
            if let json = response.result.value {
                print("JSON: \(json)")
                DispatchQueue.main.async {
                    self.playLiveSteamUsingIJKFFMoviePlayer()
                }
                self.udpTimer = Timer.scheduledTimer(timeInterval: 20, target: self, selector: #selector(self.maintainUDPStream), userInfo: nil, repeats: true)
                
            }
        }
        
    }
    
    @IBAction func goproLocalFiles(_ sender: Any) {
        //-- GoPro command controller usage
        let goproCommandController = GoProCommandController.controller
        let goproStreamListURL = goproCommandController.GoProGetMediaList()
        
        //-- Alamofire: make http request
        //-- reference: https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#http-methods
        // without response handling (default: .GET method)

        // with response handling (json Serializer)
        Alamofire.request(goproStreamListURL).responseJSON { response in
            let json: JSON = JSON(response.result.value!)

            self.getMp4InGopro(json: json)
            
            DispatchQueue.main.async {
                self.mediaList.reloadData()
            }
        }
        getMp4InLocal()
        localList.reloadData()
       
        
    }
    //TODO: - RecordVideo
    @IBAction func startRecord(_ sender: Any) {

        let goproCommandController = GoProCommandController.controller
        
        Alamofire.request(goproCommandController.GoProPrimaryMode(mode: "video"))
        
        if flagRecord == false {
            Alamofire.request(goproCommandController.GoProShutter(trigger: true))
            print("Start Record!")
            flagRecord = true
        } else {
            Alamofire.request(goproCommandController.GoProShutter(trigger: false))
            print("Stop Record!")
            flagRecord = false
        }
        setRecordButtonView(flagRecord!)
    }
    func setRecordButtonView(_ flagRecord: Bool) {
        if flag["livePlay"]!{
            let flagRecord = flagRecord
            if flagRecord == false {
                recordButton.setImage(UIImage(named: "record"), for: .normal)
            } else {
                recordButton.setImage(UIImage(named: "stop"), for: .normal)
            }
        }
    }
    //TODO: - Download media to Local
    
    @IBAction func downloadToLocal(_ sender: Any) {
        Alamofire.request(uiTextFieldSource.text!).downloadProgress(closure : { (progress) in
            print(progress.fractionCompleted)
//            self.progressView.progress = Float(progress.fractionCompleted)
        }).responseData{ (response) in
            print(response)
            print(response.result.value!)
            print(response.result.description)
            if let data = response.result.value {
                
                let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                let videoURL = documentsURL.appendingPathComponent(self.nameArray[self.selectedName!])
                do {
                    try data.write(to: videoURL)
                } catch {
                    print("Something went wrong!")
                }
                print(videoURL)
            }
        }
    }
    
    //MARK: - Functions
    /***************************************************************/
    
    
    @objc func maintainUDPStream()
    {
        let goproCommandController = GoProCommandController.controller
        let goproLiveStreamUrl = goproCommandController.GoProStartStreaming()
        Alamofire.request(goproLiveStreamUrl)
    }
//    GoProGetMediaList() get filelist from gopro input is JSON
    func getMp4InGopro(json: JSON) {
        directory = json["media"][0]["d"].stringValue
        var nFile = 0
        self.nameArray.removeAll()
        for _ in json["media"][0]["fs"] {
            let name = json["media"][0]["fs"][nFile]["n"].stringValue
            if name.hasSuffix(".MP4") {
                self.nameArray.append(name)
            }
            nFile = nFile + 1
        }
//        print(self.nameArray)
        
    }
    func getMp4InLocal(){
        let fm = FileManager.default
        let documentURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
//        print(documentURL)
        localNameArray.removeAll()
        
        do {
//            let items = try fm.contentsOfDirectory(atPath: documentURL)
            let items = try fm.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for item in items {
                let name = item.lastPathComponent
                localNameArray.append(name)
            }
        } catch {
            
        }
        print(localNameArray)
    }
    func shutdownVideo() {
        if flag["livePlay"]!{
            playerIJK!.shutdown()
            flag["livePlay"] = false
            print("close live play")
        }
        if flag["goproPlay"]!{
            playerViewController.player?.replaceCurrentItem(with: (nil))
            flag["goproPlay"] = false
            print("close video play")
        }
    }
    func playVideo(url:String){
        shutdownVideo()

        let videoURL = URL(string: url)
        let player = AVPlayer(url: videoURL!)
        
        playerViewController.player = player
        
        uiViewPreview.addSubview(playerViewController.view)
        playerViewController.view.frame = uiViewPreview.bounds
        playerViewController.showsPlaybackControls = false
        playerViewController.player!.play()
        flag["goproPlay"] = true
    }
    
    func initLiveStream() -> IJKFFMoviePlayerController{
        var videoURLInput: String!
        videoURLInput = "udp://10.5.5.100:8554"
        // initialize default setting
        let options = IJKFFOptions.byDefault()
        // URL
        let url = URL(string: videoURLInput)
        // initialization
        let player = IJKFFMoviePlayerController(contentURL: url, with: options)!
        return player
    }
    
    func playLiveSteamUsingIJKFFMoviePlayer() {
        shutdownVideo()
        playerIJK = initLiveStream()
        playerIJK!.setOptionValue("200000", forKey: "analyzeduration", of: IJKFFOptionCategory(1))
        playerIJK!.setOptionValue("nobuffer", forKey: "fflags", of: IJKFFOptionCategory(1))
        playerIJK!.setOptionValue("2048", forKey: "probsize", of: IJKFFOptionCategory(1))

        // fit scale
        //        let autoresize = UIViewAutoresizing.flexibleWidth.rawValue |
        //            UIViewAutoresizing.flexibleHeight.rawValue
        //        player.view.autoresizingMask = UIViewAutoresizing(rawValue: autoresize)
        
        playerIJK!.view.frame = uiViewPreview.bounds
        playerIJK!.scalingMode = IJKMPMovieScalingMode.aspectFit
        playerIJK!.shouldAutoplay = true
        uiViewPreview.autoresizesSubviews = true
        uiViewPreview.layer.addSublayer(playerIJK!.view.layer)
        playerIJK!.prepareToPlay()
        flag["livePlay"] = true
        
    }
    


    func setStreamingRate(streamRate: Int){
        let goproCommandCOntroller = GoProCommandController.controller
        let goproLiveStreamUrl = goproCommandCOntroller.GoProStreamBitRate(bitRate: streamRate)
        Alamofire.request(goproLiveStreamUrl)
    }
    func playGoproVideo(fileNameToPlay name: String ){
        
        
    
    }
    
    //MARK: - Delegate
    /***************************************************************/
    
    //    filesListTableView UITableView Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        var count:Int?
        
        if tableView == self.mediaList{
            count  = nameArray.count
        }
        if tableView == self.localList{
            count = localNameArray.count
        }
        return count!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: VideoTableViewCell?
        
        if tableView == self.mediaList {
            let name = nameArray[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell") as! VideoTableViewCell
            cell!.setVideoTableViewCell(file: name, type: "gopro")
        }
        
        if tableView == self.localList {
            let name = localNameArray[indexPath.row]
            cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableViewCell") as! VideoTableViewCell
            cell!.setVideoTableViewCell(file: name, type: "Local")
        }

        return cell!
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if tableView == mediaList {
            let name = nameArray[indexPath.row]
            selectedName = indexPath.row
            let goproDefaultUrl = "http://10.5.5.9:8080/Videos/DCIM/"+directory!+"/"+name
            uiTextFieldSource.text = goproDefaultUrl
        }
        if tableView == localList {
            let name = localNameArray[indexPath.row]
            selectedName = indexPath.row
            let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.absoluteString
            let goproDefaultUrl = path + name
            uiTextFieldSource.text = goproDefaultUrl
        }
        
    }

}

extension UIView {
    public func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
}

