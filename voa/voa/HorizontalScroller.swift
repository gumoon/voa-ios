//
//  HorizontalScroller.swift
//  voa
//
//  Created by huliang on 2016/11/13.
//  Copyright © 2016年 huliang. All rights reserved.
//

import UIKit

class HorizontalScroller: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    weak var delegate: HorizontalScrollerDelegate?
    
    private let VIEW_PADDING = 10
    private let VIEW_DIMENSIONS = 100
    private let VIEW_OFFSET = 100
    
    private var scroller: UIScrollView!

    var viewArray = [UIView]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        initializeScrollView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initializeScrollView()
    }
    
    func initializeScrollView() {
        scroller = UIScrollView()
        addSubview(scroller)
        
        scroller.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
        self.addConstraint(NSLayoutConstraint(item: scroller, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(scrollerTapped))
        scroller.addGestureRecognizer(tapRecognizer)
    }
    
    func scrollerTapped(gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: gesture.view)
        if let delegate = self.delegate {
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
                let view = scroller.subviews[index] as UIView
                if view.frame.contains(location) {
                    delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: index)
                    scroller.setContentOffset(CGPoint(x: view.frame.origin.x - self.frame.size.width/2 + view.frame.size.width/2, y: 0), animated: true)
                    break
                }
            }
        }
    }
    
    func viewAtIndex(index: Int) -> UIView {
        return viewArray[index]
    }
    
    func reload() {
        if let delegate = self.delegate {
            viewArray = []

            var xValue = VIEW_OFFSET
            for index in 0..<delegate.numberOfViewsForHorizontalScroller(scroller: self) {
                xValue += VIEW_PADDING
                let view = delegate.horizontalScrollerViewAtIndex(scroller: self, index: index)
                view.frame = CGRect(x: CGFloat(xValue), y: CGFloat(VIEW_PADDING), width: CGFloat(VIEW_DIMENSIONS), height: CGFloat(VIEW_DIMENSIONS))
                scroller.addSubview(view)
                xValue += VIEW_DIMENSIONS + VIEW_PADDING
                viewArray.append(view)
            }
            scroller.contentSize = CGSize(width: CGFloat(xValue+VIEW_OFFSET), height: frame.size.height)
            
            if let initialView = delegate.initialViewIndex?(scroller: self) {
                scroller.setContentOffset(CGPoint(x: CGFloat(initialView), y: CGFloat((VIEW_DIMENSIONS+(2*VIEW_PADDING)))), animated: true)
            }
        }
    }
    
    override func didMoveToSuperview() {
        reload()
    }
    
    func centerCurrentView() {
        var xFinal = scroller.contentOffset.x + CGFloat((VIEW_OFFSET/2) + VIEW_PADDING)
        let viewIndex = xFinal / CGFloat((VIEW_DIMENSIONS + (2*VIEW_PADDING)))
        xFinal = viewIndex * CGFloat(VIEW_DIMENSIONS + (2*VIEW_PADDING))
        scroller.setContentOffset(CGPoint(x: xFinal, y: 0), animated: true)
        
        if let delegate = self.delegate {
            delegate.horizontalScrollerClickedViewAtIndex(scroller: self, index: Int(viewIndex))
        }
    }
}

@objc protocol HorizontalScrollerDelegate {
    //横滑视图中有多少页面需要展示
    func numberOfViewsForHorizontalScroller(scroller: HorizontalScroller) -> Int
    
    //展示在第 index 位置显示的UIView
    func horizontalScrollerViewAtIndex(scroller: HorizontalScroller, index: Int) -> UIView
    
    //通知委托第 index 个视图被点击了
    func horizontalScrollerClickedViewAtIndex(scroller: HorizontalScroller, index: Int)
    
    //可选方法，返回初始化时显示的图片下标，默认为0
    @objc optional func initialViewIndex(scroller: HorizontalScroller) -> Int
}

extension HorizontalScroller: UIScrollViewDelegate {
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if !decelerate {
            centerCurrentView()
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        centerCurrentView()
    }
}
