//
//  VTAutoSlideView.swift
//  VTAutoSlideView
//
//  Created by hao on 2017/2/6.
//  Copyright © 2017年 Vito. All rights reserved.
//

import UIKit

// MARK: - VTDirection enum
public enum VTDirection: Int {
    case horizontal
    case vertical
   
    var collectionViewScrollDirection: UICollectionViewScrollDirection {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
    
    var scrollPosition: UICollectionViewScrollPosition {
        switch self {
        case .horizontal:
            return .centeredHorizontally
        case .vertical:
            return .centeredVertically
        }
    }
}

// MARK: - VTAutoSlideViewDataSource
@objc public protocol VTAutoSlideViewDataSource: NSObjectProtocol {
    func configuration(cell: UICollectionViewCell, for index: Int)
}

// MARK: - VTAutoSlideViewDelegate
@objc public protocol VTAutoSlideViewDelegate: NSObjectProtocol {
    @objc optional func slideView(_ slideView: VTAutoSlideView!, didSelectItemAt index: Int)
    
    /// Can use this function to detect current index
    @objc optional func slideView(_ slideView: VTAutoSlideView!, currentIndex: Int)
}

// MARK: - VTAutoSlideView
open class VTAutoSlideView: UIView {
    
    /// reuse identifier
    fileprivate static let cellIdentifier = "VTAutoSlideViewCell"
    
    fileprivate weak var collectionView: UICollectionView!
    
    /// Slide View Scroll Direction, default is horizontal
    private(set) var direction: VTDirection
    
    /// a flag to check has register cell
    private var isRegisterCell = false
    
    private var timer: Timer?
    
    open override var bounds: CGRect {
        didSet {
            // bounds change handle
            invalidateTimer()
            collectionView.collectionViewLayout.invalidateLayout()
            guard let indexPathForVisibleItem = collectionView.indexPathsForVisibleItems.first else {
                return
            }
            DispatchQueue.main.async {
                [weak self] in
                guard let strongSelf = self else { return }
                strongSelf
                    .collectionView
                    .selectItem(at: indexPathForVisibleItem,
                                animated: false,
                                scrollPosition: strongSelf.direction.scrollPosition)
                strongSelf.setupTimer()
            }
        }
    }
    
    /// 自动轮播的间距
    public var autoChangeTime: TimeInterval = 3 {
        didSet {
            setupTimer()
        }
    }
    
    /// 控制是否开启自动轮播，默认是 true
    public var activated = true {
        didSet {
            if activated {
                setupTimer()
            } else {
                invalidateTimer()
            }
        }
    }
    
    @IBOutlet public weak var dataSource: VTAutoSlideViewDataSource?
    
    @IBOutlet public weak var delegate: VTAutoSlideViewDelegate?
    
    /// 需要展示的数据源
    public var dataList = [Any]() {
        didSet {
            guard isRegisterCell else {
                fatalError("必须先调用register(cellClass:) 或 register(nib:)方法")
            }
            collectionView.reloadData()
        }
    }
    
    /// 当数据多于一个的时候才允许滚动
    fileprivate var totalCount: Int {
        return dataList.count > 1 ? dataList.count + 2 : dataList.count
    }
    
    // MARK: Lift Cycle
    public init(direction: VTDirection = .horizontal, dataSource: VTAutoSlideViewDataSource) {
        self.direction = direction
        self.dataSource = dataSource
        super.init(frame: .zero)
        
        setupCollectionView()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.direction = .horizontal
        super.init(coder: aDecoder)
        
        setupCollectionView()
    }
    
    deinit {
        invalidateTimer()
    }
    
    open override func willMove(toSuperview newSuperview: UIView?) {
        super.willMove(toSuperview: newSuperview)
        DispatchQueue.main.async {
            [weak self] in
            guard let strongSelf = self,
                strongSelf.totalCount > 1 else { return }
            strongSelf
                .collectionView
                .selectItem(at: IndexPath(row: 1, section: 0),
                            animated: false,
                            scrollPosition: strongSelf.direction.scrollPosition)
        }
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        invalidateTimer()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        setupTimer()
    }
    
    // MARK: Custom function
    
    /// register either a class or a nib from which to instantiate a cell
    open func register(cellClass: Swift.AnyClass?) {
        guard let cellClass = cellClass else {
            fatalError("cellClass 不能为空")
        }
        collectionView.register(cellClass, forCellWithReuseIdentifier: VTAutoSlideView.cellIdentifier)
        isRegisterCell = true
    }
    
    open func register(nib: UINib?) {
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
        flowLayout.scrollDirection = direction.collectionViewScrollDirection
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
        collectionView.isPagingEnabled = true
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        self.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: self.topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.bottomAnchor)
            ])
        
        
        
        self.collectionView = collectionView
    }
    
    fileprivate func setupTimer() {
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.invalidateTimer()
            if strongSelf.activated && strongSelf.dataList.count > 1{
                let timer = Timer(timeInterval: strongSelf.autoChangeTime,
                                  target: strongSelf,
                                  selector: #selector(strongSelf.autoChangeCell),
                                  userInfo: nil,
                                  repeats: false)
                RunLoop.main.add(timer, forMode: .commonModes)
                strongSelf.timer = timer
            }
        }
    }
    
    fileprivate func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    @objc fileprivate func autoChangeCell() {
        if let currentIndex = collectionView.indexPathsForVisibleItems.first {
            collectionView.scrollToItem(at: currentIndex + 1, at: direction.scrollPosition, animated: true)
        }
        setupTimer()
    }
    
    /// Converting the indexPath to dataList's real index
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

// MARK: - Handle Scroll View Did Scroll
extension VTAutoSlideView {
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
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
        
        guard cellWidth > 0 else {
            return
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
        } else if offset >= contentWidth - cellWidth {
            var targetContentOffset: CGPoint
            switch direction {
            case .horizontal:
                targetContentOffset = CGPoint(x: cellWidth, y: 0)
            case .vertical:
                targetContentOffset = CGPoint(x: 0, y: cellWidth)
            }
            
            collectionView.setContentOffset(targetContentOffset, animated: false)
            
        }
        
        var currentIndex = Int(round(offset / cellWidth))
        if currentIndex == 0{
            currentIndex = dataList.count - 1
        } else if currentIndex == totalCount - 1 {
            currentIndex = 0
        } else {
            currentIndex -= 1
        }
        delegate?.slideView?(self, currentIndex: currentIndex)
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        setupTimer()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == collectionView else { return }
        setupTimer()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        invalidateTimer()
    }
}

// MARK: - UICollectionViewDataSource
extension VTAutoSlideView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell
    {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: VTAutoSlideView.cellIdentifier, for: indexPath)
        
        dataSource?.configuration(cell: cell, for: currentIndex(indexPath: indexPath))
        
        return cell
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return totalCount
    }
}

// MARK: - UICollectionViewDelegate
extension VTAutoSlideView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath)
    {
        delegate?.slideView?(self, didSelectItemAt: currentIndex(indexPath: indexPath))
    }
}

// MARK: - UICollectionViewDelegateFlowLayout
extension VTAutoSlideView: UICollectionViewDelegateFlowLayout {
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        return collectionView.bounds.size
    }
}

// MARK: - Common function
func +(lhs: IndexPath, rhs: Int) -> IndexPath{
    return IndexPath(item: lhs.item + rhs, section: lhs.section)
}
