//
//  UseInCodeViewController.swift
//  VTAutoSlideView
//
//  Created by hao Mac Mini on 2017/2/8.
//  Copyright © 2017年 Vito. All rights reserved.
//

import UIKit
import VTAutoSlideView

class UseInCodeViewController: UIViewController {
    
    lazy var slideView: VTAutoSlideView = {
        let slideView = VTAutoSlideView(direction: .vertical, dataSource: self)
        return slideView
    }()
    
    lazy var imageList = {
        // flatMap 不同于 map 的是, flatMap 会筛选非空元素
        (1...4).flatMap { UIImage(named: "0\($0)") }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideView.register(nib: UINib(nibName: "DisplayImageCell", bundle: nibBundle))
        slideView.dataList = imageList
        slideView.activated = false // 关闭自动轮播功能
        view.addSubview(slideView)
        slideView.translatesAutoresizingMaskIntoConstraints = false
        
        // add constraints
        slideView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        slideView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20).isActive = true
        slideView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        slideView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.5).isActive = true
    }

}

extension UseInCodeViewController: VTAutoSlideViewDataSource {
    func configuration(cell: UICollectionViewCell, for index: Int)
    {
        guard let cell = cell as? DisplayImageCell else {
            return
        }
        cell.imageView.image = imageList[index]
    }
}
