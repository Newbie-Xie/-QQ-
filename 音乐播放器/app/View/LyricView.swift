//
//  LyricView.swift
//  音乐播放器
//
//  Created by 谢某某 on 16/4/24.
//  Copyright © 2016年 2期. All rights reserved.
//

import UIKit

protocol LyricViewDelegate: class {
    /// 水平滚动
    func lyricView(view: LyricView, didHorizScroll offset: CGFloat)
    /// 竖直滚动
    func lyricView(view: LyricView, didVertiScroll offset: CGFloat)
}

extension LyricViewDelegate {
    func lyricView(view: LyricView, didHorizScroll offset: CGFloat){}
    func lyricView(view: LyricView, didVertiScroll offset: CGFloat){}
}

class LyricView: UIView
{
    weak var delegate: LyricViewDelegate?
    
    var lyrics = [String]() {
        didSet{ /*lyrics = lyrics.filter{!$0.isEmpty};*/ setupHorScrollView() }
    }
    
    var index = 0 {
        didSet{
            guard !labels.isEmpty else{ return }
            let label = labels[index]
            let y = CGRectGetMaxY(label.frame)-vScrollerV.contentInset.top-labelHeight
            vScrollerV.setContentOffset(CGPointMake(0, y), animated: true)
        }
    }
    
    var currentLabel: LyricLabel {
        return labels[index]
    }
    
    /// 垂直滚动视图
    private let vScrollerV = UIScrollView()
    /// 水平滚动视图
    private let hScrollerV = UIScrollView()
    /// label数组
    private var labels = [LyricLabel]()
    /// label间的间隔
    private let labelMargin: CGFloat = 10.0
    /// label的高度
    private let labelHeight: CGFloat = 30.0
    
    private let lineView = UIView()
    
    /// 设置UI界面
    private func setupUI()
    {
        addSubview(hScrollerV)
        hScrollerV.addSubview(vScrollerV)

        hScrollerV.backgroundColor = backgroundColor
        vScrollerV.backgroundColor = backgroundColor
        
        hScrollerV.delegate = self
        vScrollerV.delegate = self
        
        hScrollerV.bounces = false
        hScrollerV.pagingEnabled = true
        
        vScrollerV.showsHorizontalScrollIndicator = false
        hScrollerV.showsHorizontalScrollIndicator = false
        hScrollerV.showsVerticalScrollIndicator = false
        vScrollerV.showsVerticalScrollIndicator = false
        
        addSubview(lineView)
        lineView.backgroundColor = .greenColor()
    }
    
    private func setupHorScrollView()
    {
        labels.forEach{ $0.removeFromSuperview() }
        labels.removeAll()
        
        let height = (labelHeight+labelMargin)*CGFloat(lyrics.count-1)+labelHeight
        vScrollerV.contentSize = CGSizeMake(0, height)
        
        for (index, lyr) in lyrics.enumerate()
        {
            let label = LyricLabel(); label.text = lyr
            label.textAlignment = .Center
            label.textColor = .whiteColor()
            vScrollerV.addSubview(label)
            
            label.snp_makeConstraints { (make) in
                make.centerX.equalTo(vScrollerV)
                make.height.equalTo(labelHeight)
                if index == 0 {
                    make.top.equalTo(vScrollerV)
                }else{
                    make.top.equalTo(labels.last!.snp_bottom).offset(labelMargin)
                }
            }
            labels.append(label)
        }
    }
    
    // MARK: - Override Method
    override func layoutSubviews() {
        super.layoutSubviews()
        hScrollerV.frame = bounds
        hScrollerV.contentSize = CGSizeMake(bounds.width*2, 0)
        vScrollerV.frame = CGRectMake(bounds.width, 0, bounds.width, bounds.height)
        
        let height = bounds.height-labelHeight
        vScrollerV.contentInset = UIEdgeInsetsMake(height * 0.5, 0, height * 0.5, 0)
        vScrollerV.contentOffset = CGPointMake(0, -height/2)
        
        lineView.frame = CGRectMake(0, bounds.height/2, bounds.width, 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI()
    }
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

}

extension LyricView: UIScrollViewDelegate
{
    func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == hScrollerV {
            delegate?.lyricView(self, didHorizScroll: scrollView.contentOffset.x)
        }else if scrollView == vScrollerV {
            delegate?.lyricView(self, didVertiScroll: scrollView.contentOffset.y)
        }
    }
}











