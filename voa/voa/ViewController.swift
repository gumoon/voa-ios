//
//  ViewController.swift
//  voa
//
//  Created by huliang on 2016/11/13.
//  Copyright © 2016年 huliang. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var dataTable: UITableView!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var scroller: HorizontalScroller!
    
    var allAlbums = [Album]()
    var currentAlbumData : (titles: [String], values: [String])?
    var currentAlbumIndex = 0
    var undoStack: [(Album, Int)] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.navigationController?.navigationBar.isTranslucent = false
        currentAlbumIndex = 0
        
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        
        dataTable.backgroundView = nil
        view.addSubview(dataTable)
        
        self.showDataForAlbum(albumIndex: currentAlbumIndex)
        
        //加载上次选中的
        loadPreviousState()
        
        scroller.delegate = self
        reloadScroller()
        
        //删除专辑和撤销上次的删除操作
        let undoButton = UIBarButtonItem(barButtonSystemItem: .undo, target: self, action: #selector(undoAction))
        undoButton.isEnabled = false
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let trashButton = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteAlbum))
        let toolbarButtonItems = [undoButton, space, trashButton]
        toolbar.setItems(toolbarButtonItems, animated: true)
        
        //当app进入后台时，保存当前选中
        NotificationCenter.default.addObserver(self, selector: #selector(saveCurrentState), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //业务数据组合
    func showDataForAlbum(albumIndex: Int) {
        if (albumIndex < allAlbums.count && albumIndex > -1) {
            let album = allAlbums[albumIndex]
            currentAlbumData = album.ae_tableRepresentation()
        } else {
            currentAlbumData = nil
        }
        
        dataTable!.reloadData()
    }
    
    //备忘录模式
    func saveCurrentState()
    {
        UserDefaults.standard.set(currentAlbumIndex, forKey: "currentAlbumIndex")
        LibraryAPI.sharedInstance.saveAlbums()
    }
    
    func loadPreviousState() {
        currentAlbumIndex = UserDefaults.standard.integer(forKey: "currentAlbumIndex")
        showDataForAlbum(albumIndex: currentAlbumIndex)
    }
    
    //增加专辑
    func addAlbumAtIndex(album: Album, index: Int) {
        LibraryAPI.sharedInstance.addAlbum(album: album, index: index)
        currentAlbumIndex = index
        reloadScroller()
    }
    
    //删除专辑
    func deleteAlbum() {
        let deleteAlbum: Album = allAlbums[currentAlbumIndex]
        
        let undoAction = (deleteAlbum, currentAlbumIndex)
        undoStack.insert(undoAction, at: 0)
        
        LibraryAPI.sharedInstance.deleteAlbum(index: currentAlbumIndex)
        reloadScroller()
        
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        let undoButton: UIBarButtonItem = barButtonItems[0]
        undoButton.isEnabled = true
        
        if allAlbums.count == 0 {
            let trashButton: UIBarButtonItem = barButtonItems[2]
            trashButton.isEnabled = false
        }
    }
    
    //撤销动作
    func undoAction() {
        let barButtonItems = toolbar.items! as [UIBarButtonItem]
        
        if undoStack.count > 0 {
            let (deletedAlbum, index) = undoStack.remove(at: 0)
            addAlbumAtIndex(album: deletedAlbum, index: index)
        }
        
        if undoStack.count == 0 {
            let undoButton: UIBarButtonItem = barButtonItems[0]
            undoButton.isEnabled = false
        }
        
        let trashButton: UIBarButtonItem = barButtonItems[2]
        trashButton.isEnabled = true
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let albumData = currentAlbumData {
            return albumData.titles.count
        } else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as UITableViewCell
        
        if let albumData = currentAlbumData {
            cell.textLabel?.text = albumData.titles[indexPath.row]

            if let detailTextLabel = cell.detailTextLabel {
                detailTextLabel.text = albumData.values[indexPath.row]
            }
        }
        
        return cell
    }
}

extension ViewController: UITableViewDelegate {
}

extension ViewController: HorizontalScrollerDelegate {
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int) {
        let previousAlbumView = scroller.viewAtIndex(index: currentAlbumIndex) as! AlbumView
        previousAlbumView.highlightAlbum(didHighlightView: false)
        
        currentAlbumIndex = index
        
        let albumView = scroller.viewAtIndex(index: index) as! AlbumView
        albumView.highlightAlbum(didHighlightView: true)
        
        showDataForAlbum(albumIndex: index)
    }
    
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int {
        return allAlbums.count
    }
    
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> UIView {
        let album = allAlbums[index]
        let albumView = AlbumView(frame: CGRect(x: 0, y: 0, width: 100, height: 100), albumCover: album.coverUrl)
        
        if currentAlbumIndex == index {
            albumView.highlightAlbum(didHighlightView: true)
        } else {
            albumView.highlightAlbum(didHighlightView: false)
        }
        
        return albumView
    }
    
    func reloadScroller() {
        allAlbums = LibraryAPI.sharedInstance.getAlbums()
        if currentAlbumIndex < 0 {
            currentAlbumIndex = 0
        } else if currentAlbumIndex >= allAlbums.count {
            currentAlbumIndex = allAlbums.count - 1
        }
        
        scroller.reload()
        showDataForAlbum(albumIndex: currentAlbumIndex)
    }
    
    func initialViewIndex(scroller: HorizontalScroller) -> Int {
        return currentAlbumIndex
    }
}
