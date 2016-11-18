//
//  AlbumView.swift
//  voa
//
//  Created by huliang on 2016/11/13.
//  Copyright © 2016年 huliang. All rights reserved.
//

import UIKit

class AlbumView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    private var coverImage: UIImageView!
    private var indicator: UIActivityIndicatorView!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(frame: CGRect, albumCover: String) {
        super.init(frame: frame)
        backgroundColor = UIColor.black
        coverImage = UIImageView(frame: CGRect(x: 5, y: 5, width: frame.size.width - 10, height: frame.size.height - 10))
        addSubview(coverImage)
        
        //图片加载完后，让加载器消失；观察者模式
        coverImage.addObserver(self, forKeyPath: "image", options: [], context: nil)
        
        indicator = UIActivityIndicatorView()
        indicator.center = center
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.startAnimating()
        addSubview(indicator)
        
        NotificationCenter.default.post(name: Notification.Name("BLDownloadImageNotification"), object: self, userInfo: ["imageView": coverImage, "coverUrl": albumCover])
    }
    
    deinit {
        //
        coverImage.removeObserver(self, forKeyPath: "image")
    }
    
    func highlightAlbum(didHighlightView: Bool) {
        if didHighlightView == true {
            backgroundColor = UIColor.white
        } else {
            backgroundColor = UIColor.black
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "image" {
            indicator.stopAnimating()
        }
    }
}
