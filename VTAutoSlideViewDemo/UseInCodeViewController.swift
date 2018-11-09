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
        // compactMap 不同于 map 的是, compactMap 会筛选非空元素
        (1...4).compactMap { UIImage(named: "0\($0)") }
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        slideView.register(nib: UINib(nibName: "DisplayImageCell", bundle: nibBundle))
        slideView.dataList = imageList
        slideView.activated = false // 关闭自动轮播功能
        view.addSubview(slideView)
        slideView.translatesAutoresizingMaskIntoConstraints = false
        
        // add constraints
        NSLayoutConstraint.activate([
            slideView.leadingAnchor.constraint(equalTo: view.safeLeadingAnchor),
            slideView.topAnchor.constraint(equalTo: safeTopAnchor, constant: 20),
            slideView.trailingAnchor.constraint(equalTo: view.safeTrailingAnchor),
            slideView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.5)
            ])
        
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

extension UIViewController {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.bottomAnchor
        }
    }
}

extension UIView {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.topAnchor
        } else {
            return self.topAnchor
        }
    }
    
    var safeBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.bottomAnchor
        } else {
            return self.bottomAnchor
        }
    }
    
    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.leadingAnchor
        } else {
            return self.leadingAnchor
        }
    }
    
    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return self.safeAreaLayoutGuide.trailingAnchor
        } else {
            return self.trailingAnchor
        }
    }
}
