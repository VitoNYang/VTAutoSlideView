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
   
    var collectionViewScrollDirection: UICollectionView.ScrollDirection {
        switch self {
        case .horizontal:
            return .horizontal
        case .vertical:
            return .vertical
        }
    }
    
    var scrollPosition: UICollectionView.ScrollPosition {
        switch self {
        case .horizontal:
            return .centeredHorizontally
        case .vertical:
            return .centeredVertically
        }
    }
}

public enum VTSlideMode {
    case manual
    case autoSlide(duration: TimeInterval)
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
    // MARK: Private Property
    /// reuse identifier
    private static let cellIdentifier = "VTAutoSlideViewCell"
    private weak var collectionView: UICollectionView!
    
    /// Slide View Scroll Direction, default is horizontal
    private(set) var direction: VTDirection
    
    /// a flag to check has register cell
    private var isRegisterCell = false
    
    private var timer: Timer?
    
    /// 当数据多于一个的时候才允许滚动
    private var totalCount: Int {
        return dataList.count > 1 ? dataList.count + 2 : dataList.count
    }
    
    private var autoSlideDuration: TimeInterval {
        if case let .autoSlide(duration) = slideMode {
            return duration
        } else {
            return 0
        }
    }
    
    // MARK: Public Property
    open override var bounds: CGRect {
        didSet {
            guard bounds != oldValue else { return }
            // bounds change handle
            collectionView.collectionViewLayout.invalidateLayout()
            guard let indexPathForVisibleItem = collectionView.indexPathsForVisibleItems.first else {
                return
            }
            runOnMainThread {
                [weak self] in
                guard let self else { return }
                self.collectionView
                    .selectItem(at: indexPathForVisibleItem,
                                animated: false,
                                scrollPosition: self.direction.scrollPosition)
                self.setupTimerIfNeeded()
            }
        }
    }
    
    public var slideMode: VTSlideMode = .autoSlide(duration: 3) {
        didSet {
            switch slideMode {
            case .manual:
                invalidateTimer()
            case .autoSlide:
                setupTimerIfNeeded()
            }
        }
    }
    
    public var isAutoSlide: Bool {
        if autoSlideDuration > 0 {
            return true
        } else {
            return false
        }
    }

    public var currentIndex: Int = 0 {
        didSet {
            guard currentIndex != oldValue else { return }
            delegate?.slideView?(self, currentIndex: currentIndex)
//            guard dataList.count > 1 else { return }
//            invalidateTimer()
//            collectionView
//                .selectItem(at: IndexPath(item: currentIndex + 1, section: 0),
//                            animated: false,
//                            scrollPosition: direction.scrollPosition)
//            setupTimerIfNeeded()
        }
    }
    
    @IBOutlet public weak var dataSource: VTAutoSlideViewDataSource?
    
    @IBOutlet public weak var delegate: VTAutoSlideViewDelegate?
    
    /// 需要展示的数据源
    public var dataList = [Any]() {
        didSet {
            precondition(isRegisterCell, "必须先调用register(cellClass:) 或 register(nib:)方法")
            collectionView.reloadData()
        }
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
        print("will move")
        guard newSuperview != nil else { return }
        runOnMainThread {
            [weak self] in
            guard let self, self.totalCount > 1 else { return }
            self.collectionView
                .selectItem(at: IndexPath(item: 1, section: 0),
                            animated: false,
                            scrollPosition: self.direction.scrollPosition)
        }
    }
    
    open override func removeFromSuperview() {
        super.removeFromSuperview()
        
        invalidateTimer()
    }
    
    open override func didMoveToSuperview() {
        super.didMoveToSuperview()
        
        print("move to superview")
        setupTimerIfNeeded()
    }
    
    // MARK: Public function
    
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
    
    // MARK: Private function
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
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.topAnchor.constraint(equalTo: topAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: bottomAnchor)
            ])
        
        self.collectionView = collectionView
    }
    
    @MainActor private func setupTimerIfNeeded() {
        invalidateTimer()
        guard superview != nil, autoSlideDuration > 0, dataList.count > 1 else {
            return
        }
        let timer = Timer(timeInterval: autoSlideDuration,
                          target: self,
                          selector: #selector(slideCellToNext),
                          userInfo: nil,
                          repeats: false)
        RunLoop.main.add(timer, forMode: .common)
        self.timer = timer
    }
    
    private func invalidateTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    private func runOnMainThread(_ action: @escaping () -> Void) {
        DispatchQueue.main.async(execute: action)
    }
    
    @objc private func slideCellToNext() {
        if let currentIndex = collectionView.indexPathsForVisibleItems.first {
            collectionView.scrollToItem(at: currentIndex + 1, at: direction.scrollPosition, animated: true)
        }
        setupTimerIfNeeded()
    }
    
    /// Converting the indexPath to dataList's real index
    private func currentIndex(indexPath: IndexPath) -> Int {
        var currentIndex: Int
        switch indexPath.item {
        case 0:
            currentIndex = dataList.count - 1
        case totalCount - 1:
            currentIndex = 0
        default:
            currentIndex = indexPath.item - 1
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
        if currentIndex == 0 {
            currentIndex = dataList.count - 1
        } else if currentIndex == totalCount - 1 {
            currentIndex = 0
        } else {
            currentIndex -= 1
        }
        self.currentIndex = currentIndex
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        guard scrollView == collectionView else { return }
        setupTimerIfNeeded()
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        guard scrollView == collectionView else { return }
        setupTimerIfNeeded()
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
func + (lhs: IndexPath, rhs: Int) -> IndexPath{
    return IndexPath(item: lhs.item + rhs, section: lhs.section)
}
