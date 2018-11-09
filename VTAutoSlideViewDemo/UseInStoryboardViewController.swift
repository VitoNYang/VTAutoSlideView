//
//  UseInStoryboardViewController.swift
//  VTAutoSlideViewDemo
//
//  Created by hao on 2017/2/7.
//  Copyright © 2017年 Vito. All rights reserved.
//

import UIKit
import VTAutoSlideView

class UseInStoryboardViewController: UIViewController {
    
    @IBOutlet weak var slideView: VTAutoSlideView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    lazy var imageList = {
        (1...4).compactMap { UIImage(named: "0\($0)") }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        func setupSlideView() {
            slideView.register(nib: UINib(nibName: "DisplayImageCell", bundle: nibBundle))
            slideView.dataSource = self
            slideView.delegate = self
            slideView.dataList = imageList
            slideView.autoChangeTime = 1
        }
        
        func setupPageControl() {
            pageControl.numberOfPages = imageList.count
            pageControl.currentPage = 0
        }
        setupSlideView()
        setupPageControl()
    }
}

extension UseInStoryboardViewController: VTAutoSlideViewDataSource {
    func configuration(cell: UICollectionViewCell, for index: Int)
    {
        guard let cell = cell as? DisplayImageCell else {
            return
        }
        cell.imageView.image = imageList[index]
    }
}

extension UseInStoryboardViewController: VTAutoSlideViewDelegate {
    func slideView(_ slideView: VTAutoSlideView, didSelectItemAt currentIndex: Int) {
        print("click > \(currentIndex)")
    }
    
    func slideView(_ slideView: VTAutoSlideView, currentIndex: Int) {
        pageControl.currentPage = currentIndex
    }
}

