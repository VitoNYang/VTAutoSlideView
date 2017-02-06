//
//  VTAutoSlideView.swift
//  VTAutoSlideView
//
//  Created by hao on 2017/2/6.
//  Copyright © 2017年 Vito. All rights reserved.
//

import UIKit

enum VTDirection: Int {
    case horizontal
    case vertical
    
    func toCollectionViewScrollDirection() -> UICollectionViewScrollDirection {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
}

@objc protocol VTAutoSlideViewDataSource: NSObjectProtocol{
    func configuration(cell: UICollectionViewCell, for index: Int)
}

@objc protocol VTAutoSlideViewDelegate {
    func slideView(_ slideView: VTAutoSlideView, didSelectItemAt index: Int)
}

class VTAutoSlideView: UIView {
    
    fileprivate static let cellIdentifier = "VTAutoSlideViewCell"
    
    fileprivate weak var collectionView: UICollectionView!
    
    private(set) var direction: VTDirection
    
    private var isRegisterCell = false
    
    @IBOutlet weak var dataSource: VTAutoSlideViewDataSource?
    
    @IBOutlet weak var delegate: VTAutoSlideViewDelegate?
    
    var dataList = [Any]() {
        didSet {
            guard isRegisterCell else {
                fatalError("必须先调用register(cellClass:) 或 register(nib:)方法")
            }
            collectionView.reloadData()
        }
    }
    
    fileprivate var totalCount: Int {
        return dataList.count > 0 ? dataList.count + 2 : 0
    }
    
    init(direction: VTDirection = .horizontal, dataSource: VTAutoSlideViewDataSource) {
        self.direction = direction
        self.dataSource = dataSource
        super.init(frame: .zero)
        
        setupCollectionView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        self.direction = .horizontal
        super.init(coder: aDecoder)
        
        setupCollectionView()
    }
    
    override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        print("willMove to SuperView")
        DispatchQueue.main.async {
            if self.totalCount != 0 {
                self.collectionView.selectItem(at: IndexPath.init(row: 1, section: 0), animated: false, scrollPosition: self.direction == .vertical ? .centeredVertically : .centeredHorizontally)
            }
        }
    }
    
    func register(cellClass: Swift.AnyClass?) {
        guard let cellClass = cellClass else {
            fatalError("cellClass 不能为空")
        }
        collectionView.register(cellClass, forCellWithReuseIdentifier: VTAutoSlideView.cellIdentifier)
        isRegisterCell = true
    }
    
    func register(nib: UINib?) {
        guard let nib = nib else {
            fatalError("nib 不能为空")
        }
        collectionView.register(nib, forCellWithReuseIdentifier: VTAutoSlideView.cellIdentifier)
        isRegisterCell = true
    }
    
    private func setupCollectionView() {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = direction.toCollectionViewScrollDirection()
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
        
        collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        collectionView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        
        self.collectionView = collectionView
    }
    
    fileprivate func currentIndex(indexPath: IndexPath) -> Int {
        var currentIndex: Int
        switch indexPath.row {
        case 0:
            currentIndex = dataList.count - 1
        case totalCount - 1:
            currentIndex = 0
        default:
            currentIndex = indexPath.row - 1
        }
        return currentIndex
    }
}

extension VTAutoSlideView {
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        guard scrollView == collectionView else { return }
        var offset: CGFloat
        var contentWidth: CGFloat
        let cellWidth: CGFloat
        
        switch direction {
        case .horizontal:
            offset = scrollView.contentOffset.x
            contentWidth = scrollView.contentSize.width
            cellWidth = scrollView.bounds.width
        case .vertical:
            offset = scrollView.contentOffset.y
            contentWidth = scrollView.contentSize.height
            cellWidth = scrollView.bounds.height
        }
        
        if offset <= 0 {
            var targetContentOffset: CGPoint
            switch direction {
            case .horizontal:
                targetContentOffset = CGPoint(x: contentWidth - 2 * cellWidth, y: 0)
            case .vertical:
                targetContentOffset = CGPoint(x: 0, y: contentWidth - 2 * cellWidth)
            }
            
            collectionView.setContentOffset(targetContentOffset, animated: false)
        } else if offset > contentWidth - cellWidth {
            var targetContentOffset: CGPoint
            switch direction {
            case .horizontal:
                targetContentOffset = CGPoint(x: cellWidth, y: 0)
            case .vertical:
                targetContentOffset = CGPoint(x: 0, y: cellWidth)
            }
            
            collectionView.setContentOffset(targetContentOffset, animated: false)
        }
        
    }
}

extension VTAutoSlideView: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VTAutoSlideView.cellIdentifier, for: indexPath)
        
        dataSource?.configuration(cell: cell, for: currentIndex(indexPath: indexPath))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return totalCount
    }
}

extension VTAutoSlideView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        delegate?.slideView(self, didSelectItemAt: currentIndex(indexPath: indexPath))
    }
}

extension VTAutoSlideView: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return collectionView.bounds.size
    }
}
