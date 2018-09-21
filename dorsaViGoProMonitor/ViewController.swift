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

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate, UICollectionViewDataSource {

    

    
    
    @IBOutlet weak var uiTextFieldSource: UITextField!
    @IBOutlet weak var uiButtonStartStreaming: UIButton!
    @IBOutlet weak var uiViewPreview: UIView!
    @IBOutlet weak var mediaList: UITableView!
    @IBOutlet weak var uiTextFieldStreamRate: UITextField!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var localList: UITableView!
    @IBOutlet weak var photoCollect: UICollectionView!
    @IBOutlet weak var process: UIProgressView!
    
    
//    @IBOutlet weak var screenShotView: UIImageView!
    
    var nameArray = [String]()
    var localNameArray = [String]()
    var photoArray = [String]()
    var photoImage = Dictionary<String,UIImage>()
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
        photoCollect.delegate = self
        photoCollect.dataSource = self
        photoCollect.register(UINib(nibName: "PhotoViewCell", bundle: nil), forCellWithReuseIdentifier: "PhotoViewCell")
        // Do any additional setup after loading the view, typically from a nib.
        uiTextFieldStreamRate.text = "1000000"
        flagRecord = false
        setRecordButtonView(flagRecord!)
        playerIJK = initLiveStream()
        process.progress = 0.0
        reload()
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
    //TODO: - Take a ScreenShot
   
    @IBAction func screenShot(_ sender: Any) {
        let screen = uiViewPreview
        let image = screen?.takeScreenshot()
        let nameTime = getTodayString() + ".png"
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let destinationPath = documentsPath.appendingPathComponent(nameTime)
        do {
            try UIImageJPEGRepresentation(image!,1.0)?.write(to: destinationPath, options: .atomic)
        } catch {
            
        }
        reload()
        
    }
    
    
    //TODO: - Download media to Local
    
    @IBAction func downloadToLocal(_ sender: Any) {
        Alamofire.request(uiTextFieldSource.text!).downloadProgress(closure : { (progress) in
            print(progress.fractionCompleted)
            self.process.progress = Float(progress.fractionCompleted)
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
                self.reload()
            }
        }
    }
    
    //TODO: - ReloadLocal
    
    @IBAction func reloadLocal(_ sender: Any) {
       reload()
    }
    func reload(){
        getMp4InLocal()
        localList.reloadData()
        photoCollect.reloadData()
    }
    //TODO: - Delet local files
    
    @IBAction func deletLocalFile(_ sender: Any) {
        
        let alert = UIAlertController(title: "Alert", message: "DELET ALL FILES?", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "DeletAll", style: UIAlertActionStyle.default, handler: { (action:UIAlertAction) in
            
            let documentsUrl =  FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            do {
                let fileURLs = try FileManager.default.contentsOfDirectory(at: documentsUrl,
                                                                           includingPropertiesForKeys: nil,
                                                                           options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                for fileURL in fileURLs {
                    
                    try FileManager.default.removeItem(at: fileURL)
                    
                    //                if fileURL.pathExtension == "mp3" {
                    //                    try FileManager.default.removeItem(at: fileURL)
                    //                }
                }
            } catch  { print(error) }
            self.reload()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
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
        photoArray.removeAll()
        photoImage.removeAll()
        
        
        do {
//            let items = try fm.contentsOfDirectory(atPath: documentURL)
            let items = try fm.contentsOfDirectory(at: documentURL, includingPropertiesForKeys: nil, options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            for item in items {
                
                if item.pathExtension == "MP4"{
                    let name = item.lastPathComponent
                    localNameArray.append(name)
                } else {
                
                    let name = item.lastPathComponent
                    photoArray.append(name)
                    photoImage[name] = UIImage(contentsOfFile: item.path)
                    
                }
                
            }
        } catch {
            
        }
        print(photoArray)
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
    
    func getTodayString() -> String{
        
        let date = Date()
        let calender = Calendar.current
        let components = calender.dateComponents([.year,.month,.day,.hour,.minute,.second], from: date)
        
        let year = components.year
        let month = components.month
        let day = components.day
        let hour = components.hour
        let minute = components.minute
        let second = components.second
        
        let today_string = String(year!) + "-" + String(month!) + "-" + String(day!) + " " + String(hour!)  + ":" + String(minute!) + ":" +  String(second!)
        
        return today_string
        
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
    
    // CollectionView Delegate
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        var cell: PhotoViewCell?
        if collectionView == self.photoCollect {
            let name = photoArray[indexPath.row]
            let image = photoImage[name]
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
            cell!.setPhotoCell(image!, name: name)
        }
        
        return cell!
    }
    
    

}

extension UIView {
    public func removeAllSubviews() {
        for subview in self.subviews {
            subview.removeFromSuperview()
        }
    }
    
    func takeScreenshot() -> UIImage {
        
        // Begin context
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, false, UIScreen.main.scale)
        
        // Draw view in that context
        drawHierarchy(in: self.bounds, afterScreenUpdates: true)
        
        // And finally, get image
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        if (image != nil)
        {
            return image!
        }
        return UIImage()
    }
    
}

