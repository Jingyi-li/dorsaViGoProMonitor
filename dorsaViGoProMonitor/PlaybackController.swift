//
//  PlaybackController.swift
//  dorsaViGoProMonitor
//
//  Created by Jingyi LI on 10/9/18.
//  Copyright © 2018 dorsaVi Hardware. All rights reserved.
//

import Foundation
import AVKit

class PlaybackController: NSObject, AVPlayerItemMetadataCollectorPushDelegate {
    
    let player = AVPlayer()
    var playerItem: AVPlayerItem!
    var metadataCollector: AVPlayerItemMetadataCollector!
    
    func prepareToPlay(url: URL) {
        metadataCollector = AVPlayerItemMetadataCollector()
        metadataCollector.setDelegate(self, queue: DispatchQueue.main)
        
        playerItem = AVPlayerItem(url: url)
        playerItem.add(metadataCollector)
        
        player.replaceCurrentItem(with: playerItem)
    }
    
    func metadataCollector(_ metadataCollector: AVPlayerItemMetadataCollector,
                           didCollect metadataGroups: [AVDateRangeMetadataGroup],
                           indexesOfNewGroups: IndexSet,
                           indexesOfModifiedGroups: IndexSet) {
        // Process metadata
    }
}
