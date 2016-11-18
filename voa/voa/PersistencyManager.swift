//
//  PersistencyManager.swift
//  voa
//
//  Created by huliang on 2016/11/13.
//  Copyright © 2016年 huliang. All rights reserved.
//

import UIKit

class PersistencyManager: NSObject {
    private var albums = [Album]()
    
    override init() {
        super.init()
        if let data = NSData(contentsOfFile: NSHomeDirectory().appending("/Documents/albums1.bin")) {
            let unarchiveAlbums = NSKeyedUnarchiver.unarchiveObject(with: data as Data) as! [Album]?
            if let unwarppedAlbum = unarchiveAlbums {
                albums = unwarppedAlbum
            }
        } else {
            createPlaceholderAlbum()
        }
    }
    
    func createPlaceholderAlbum() {
        //Dummy list of albums
        let album1 = Album(title: "Best of Bowie",
                           artist: "David Bowie",
                           genre: "Pop",
                           coverUrl: "http://imgs.soufun.com/news/2014_12/24/house/1419408695022_000.jpg",
                           year: "1992")
        
        let album2 = Album(title: "It's My Life",
                           artist: "No Doubt",
                           genre: "Pop",
                           coverUrl: "http://thumbs.dreamstime.com/z/%D3%EB%CB%E1%D6%B5tup%BA%A3%B5%BA%B5%C4%C8%C8%B4%F8%BA%A3-%B7%E7%BE%B0-%CC%A9%B9%FA-60157891.jpg",
                           year: "2003")
        
        let album3 = Album(title: "Nothing Like The Sun",
                           artist: "Sting",
                           genre: "Pop",
                           coverUrl: "http://file27.mafengwo.net/M00/BE/F4/wKgB6lSKLvSAeR6sAAqbfnNiv8k56.groupinfo.w665_500.jpeg",
                           year: "1999")
        
        let album4 = Album(title: "Staring at the Sun",
                           artist: "U2",
                           genre: "Pop",
                           coverUrl: "http://imgs.soufun.com/news/2014_12/24/house/1419408695022_000.jpg",
                           year: "2000")
        
        let album5 = Album(title: "American Pie",
                           artist: "Madonna",
                           genre: "Pop",
                           coverUrl: "http://77fkxu.com1.z0.glb.clouddn.com/20130427/1367044809_48720.jpg",
                           year: "2000")
        
        albums = [album1, album2, album3, album4, album5]
        saveAlbums()
    }
    
    func getAlbums() -> [Album] {
        return albums
    }
    
    func addAlbum(album: Album, index: Int) {
        if albums.count >= index {
            albums.insert(album, at: index)
        } else {
            albums.append(album)
        }
    }
    
    func saveAlbums() {
        let filename = NSHomeDirectory().appending("/Documents/albums.bin")
        let data = NSKeyedArchiver.archivedData(withRootObject: albums)
        let options = NSData.WritingOptions()
        do {
            try data.write(to: URL(fileURLWithPath: filename), options: options)
        } catch  {
            
        }
        
    }
    
    func deleteAlbumAtIndex(index: Int) {
        albums.remove(at: index)
    }
    
    func saveImage(image: UIImage, filename: String) {
        let path = NSHomeDirectory().appending("/Documents/\(filename)")
        let data = UIImagePNGRepresentation(image)
        
        let url = URL(fileURLWithPath: path)
        let options = NSData.WritingOptions()

        do {
            try data?.write(to: url, options: options)
        } catch  {
            
        }
    }
    
    func getImage(filename: String) -> UIImage? {
        let path = NSHomeDirectory().appending("/Documents1/\(filename)")
        var data: Data
        do {
            try data = NSData(contentsOfFile: path, options: .uncachedRead) as Data
        } catch  {
            return nil
        }
        
        return UIImage(data: data)
    }
}

