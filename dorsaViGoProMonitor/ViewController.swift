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

class ViewController: UIViewController {
    
    @IBOutlet weak var uiTextFieldSource: UITextField!
    @IBOutlet weak var uiButtonStartStreaming: UIButton!
    @IBOutlet weak var uiViewPreview: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func uiButtonStartStreamingOnPressed(_ sender: Any) {
        var videoURLInput: String!
        videoURLInput = uiTextFieldSource.text
        let videoURL = URL(string: videoURLInput)
        let player = AVPlayer(url: videoURL!)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        uiViewPreview.addSubview(playerViewController.view)
        playerViewController.view.frame = uiViewPreview.bounds
        playerViewController.showsPlaybackControls = false
        playerViewController.player!.play()
        
    }
    
    @IBAction func goproStream(_ sender: Any) {
        //-- GoPro command controller usage
        let goproCommandController = GoProCommandController.controller
        let goproStreamListURL = goproCommandController.GoProStartStreaming()
        
        //-- Alamofire: make http request
        //-- reference: https://github.com/Alamofire/Alamofire/blob/master/Documentation/Usage.md#http-methods
        // without response handling (default: .GET method)
        Alamofire.request(goproStreamListURL)
        // with response handling (json Serializer)
        Alamofire.request(goproStreamListURL).responseJSON { response in
            let json: JSON = JSON(response.result.value!)
            if json["status"] == "0"{
                print("Connect Success!")
            }
            
        }
    }
    
}

