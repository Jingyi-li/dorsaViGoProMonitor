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
    
    var nameArray = [String]()
    var directory: String?
    var selectedName: Int?
    var udpTimer: Timer!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        mediaList.delegate = self
        mediaList.dataSource = self
        mediaList.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        // Do any additional setup after loading the view, typically from a nib.
        uiTextFieldStreamRate.text = "1000000"
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
//        Alamofire.request(goproStreamListURL)
        // with response handling (json Serializer)
        Alamofire.request(goproStreamListURL).responseJSON { response in
            let json: JSON = JSON(response.result.value!)
//            print(json)
            self.getMp4InGopro(json: json)
            
            DispatchQueue.main.async {
                self.mediaList.reloadData()
            }
        }
       
        
    }
    
    
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
        for file in json["media"][0]["fs"] {
            let name = json["media"][0]["fs"][nFile]["n"].stringValue
            if name.hasSuffix(".MP4") {
                self.nameArray.append(name)
            }
            nFile = nFile + 1
        }
        print(self.nameArray)
        
    }
    func playVideo(url:String){
        let videoURL = URL(string: url)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        uiViewPreview.addSubview(playerViewController.view)
        playerViewController.view.frame = uiViewPreview.bounds
        playerViewController.showsPlaybackControls = false
        playerViewController.player!.play()
    }
    
    func playLiveSteamUsingIJKFFMoviePlayer()
    {
        var videoURLInput: String!
//        videoURLInput = uiTextFieldSource.text
        videoURLInput = "udp://10.5.5.100:8554"
        // initialize default setting
        let options = IJKFFOptions.byDefault()
        // URL
        let url = URL(string: videoURLInput)
        // initialization
        let player = IJKFFMoviePlayerController(contentURL: url, with: options)!
        player.setPlayerOptionValue("nobuffer", forKey: "fflags")
        // fit scale
        //        let autoresize = UIViewAutoresizing.flexibleWidth.rawValue |
        //            UIViewAutoresizing.flexibleHeight.rawValue
        //        player.view.autoresizingMask = UIViewAutoresizing(rawValue: autoresize)
        
        player.view.frame = uiViewPreview.bounds
        player.scalingMode = IJKMPMovieScalingMode.aspectFit
        player.shouldAutoplay = true
        uiViewPreview.autoresizesSubviews = true
        uiViewPreview.layer.addSublayer(player.view.layer)
        player.prepareToPlay()
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
        return nameArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = nameArray[indexPath.row]
        let cell: UITableViewCell = self.mediaList.dequeueReusableCell(withIdentifier: "cell") as UITableViewCell!
        cell.textLabel?.text = name
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = nameArray[indexPath.row]
        let goproDefaultUrl = "http://10.5.5.9:8080/Videos/DCIM/"+directory!+"/"+name
        uiTextFieldSource.text = goproDefaultUrl
        
    }
        
}

