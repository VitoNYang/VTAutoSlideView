//
//  ViewController.swift
//  VTAutoSlideViewDemo
//
//  Created by hao on 2017/2/7.
//  Copyright © 2017年 Vito. All rights reserved.
//

import UIKit
import VTAutoSlideView

class ViewController: UIViewController {
    
    @IBOutlet weak var slideView: VTAutoSlideView!
    
    lazy var imageList = {
        (1...4).map{ "0\($0)" }.map{ UIImage(named: $0) }.filter{ $0 != nil }.map{ $0! }
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        slideView.register(nib: UINib(nibName: "DisplayImageCell", bundle: nibBundle))
        slideView.dataSource = self
        slideView.dataList = imageList
    }
}

extension ViewController: VTAutoSlideViewDataSource {
    func configuration(cell: UICollectionViewCell, for index: Int)
    {
        guard let cell = cell as? DisplayImageCell else {
            return
        }
        cell.imageView.image = imageList[index]
    }
}

