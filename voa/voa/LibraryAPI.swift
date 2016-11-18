//
//  LibraryAPI.swift
//  voa
//
//  Created by huliang on 2016/11/13.
//  Copyright © 2016年 huliang. All rights reserved.
//

import UIKit

class LibraryAPI: NSObject {
    private let persistencyManager: PersistencyManager
    private let httpClient: HTTPClient
    private let isOnline: Bool
    
    class var sharedInstance: LibraryAPI {
        struct Singleton {
            static let instance = LibraryAPI()
        }
        
        return Singleton.instance
    }
    
    override init() {
        persistencyManager = PersistencyManager()
        httpClient = HTTPClient()
        isOnline = false
        
        super.init()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.downloadImage), name: Notification.Name("BLDownloadImageNotification"), object: nil)
    }
    
    func getAlbums() -> [Album] {
        return persistencyManager.getAlbums()
    }
    
    func addAlbum(album: Album, index: Int) {
        persistencyManager.addAlbum(album: album, index: index)
        if isOnline {
            httpClient.postRequest("/api/addAlbum", body: album.desc())
        }
    }
    
    func deleteAlbum(index: Int) {
        persistencyManager.deleteAlbumAtIndex(index: index)
        if isOnline {
            httpClient.postRequest("/api/deleteAlbum", body: "\(index)")
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func downloadImage(notification: Notification) {
        let userInfo = notification.userInfo as! [String: AnyObject]
        let imageView = userInfo["imageView"] as! UIImageView?
        let coverUrl = userInfo["coverUrl"] as! NSString
        
        if let imageViewUnWrapped = imageView {
            imageViewUnWrapped.image = persistencyManager.getImage(filename: coverUrl.lastPathComponent)
            if imageViewUnWrapped.image == nil {
                print("no file cache")
                let downloadImage = self.httpClient.downloadImage(coverUrl as String)
                imageViewUnWrapped.image = downloadImage
                self.persistencyManager.saveImage(image: downloadImage, filename: coverUrl.lastPathComponent)
            }
        }
    }
    
    func saveAlbums() {
        persistencyManager.saveAlbums()
    }
}
