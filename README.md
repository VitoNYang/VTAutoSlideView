# VTAutoSlideView
![GitHub release (latest SemVer including pre-releases)](https://img.shields.io/github/v/release/VitoNYang/VTAutoSlideView)
![Version](https://img.shields.io/cocoapods/p/VTAutoSlideView.svg?style=flat)
![GitHub](https://img.shields.io/github/license/VitoNYang/VTAutoSlideView)
![Swift Version](https://img.shields.io/badge/swift-5.7-orange.svg)
![Build Status](https://github.com/VitoNYang/VTAutoSlideView/workflows/Build/badge.svg)

### A Common Slide View (aka. Carousel) build by UICollectionView.
#### Carousel is offen used to present Images / News / Events etc. The common use cases are really numerous and need no further explanation. so the *VTAutoSlideView* is here, let's see how to use it in our project😊

## Requirements
- iOS 11.0+
- Xcode 14.0+
- Swift 5.7+


## Installation
#### CocoaPods (Deprecated)
- Added `pod 'VTAutoSlideView'` to your Podfile.
- Then run `pod install` or `pod update` in the terminal.

#### SPM
```swift
.package(url: "https://github.com/VitoNYang/VTAutoSlideView.git")
```

## Quick Start
#### Storyboard / Xib (Note: Storyboard and Xib only support horizontal scroll)

1. in Storyboard or Xib create a View, and set the View's class as `VTAutoSlideView`,
2. create a UICollectionViewCell and build as the UI as you want,
3. register your cell in the caller, and setup VTAutoSlideView `dataSource` and `dataList`.

	``` swift
	@IBOutlet weak var slideView: VTAutoSlideView!
	    
	// Your data sources
	lazy var imageList = {
	    (1...4).map{ "0\($0)" }.map{ UIImage(named: $0) }.filter{ $0 != nil }.map{ $0! }
	}()
	
	override func viewDidLoad() {
	    super.viewDidLoad()
	    // register your CollectionViewCell first
	    // Case 1: use Xib
	    slideView.register(nib: UINib(nibName: "DisplayImageCell", bundle: nibBundle))
	    
	    // Case 2: Or use pure code
	    //slideView.register(cellClass: DisplayImageCell.self)
	    
	    slideView.dataSource = self
	    slideView.dataList = imageList
	}
	```
4. implement VTAutoSlideViewDataSource's configuration(cell:for) method and configure your cell

	``` swift
	extension ViewController: VTAutoSlideViewDataSource {
    	func configuration(cell: UICollectionViewCell, for index: Int)
    	{
           guard let cell = cell as? DisplayImageCell else {
            	   return
        	 }
        	 cell.imageView.image = imageList[index]
    	}
	}
	```
5. finally, all should be set up! Run your project and if anything is configured, it should work fine🍻🍻

### Code
1. Create VTAutoSlideView with direction and setup `dataSource`
`let slideView = VTAutoSlideView(direction: .vertical, dataSource: self)`
2. register cell，and set `dataList`

	``` swift
    slideView.register(nib: UINib(nibName: "DisplayImageCell", bundle: nibBundle))
    slideView.dataList = imageList
    slideView.activated = false // disable auto slide
    view.addSubview(slideView)
    slideView.translatesAutoresizingMaskIntoConstraints = false
        
    // add constraints
    slideView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
    slideView.topAnchor.constraint(equalTo: topLayoutGuide.bottomAnchor, constant: 20).isActive = true
    slideView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
    slideView.heightAnchor.constraint(equalToConstant: view.bounds.height * 0.5).isActive = true
	```
3. 实现 VTAutoSlideViewDataSource 的 configuration(cell:for) 方法，配置你的 cell (参考 Storyboard / Xib 中的代码)
4. 没有配置错的话，一切也已经可以正常运行起来了。

## Update Notes
* Updated at 01/04/2023: Fixed a potential crash issue.
* 更新至 08/03/2023。 Support SPM, and update to Swift 5.7, the minimum support iOS version update to iOS 11。
* 更新至 05/12/2019。 更新至Swift 5, 同时添加了Github workflows 来做持续集成。
* 更新至 27/08/2018。 修复了一个会导致crash的bug , 修改demo 适配iPhone X。
* 更新至 18/05/2017。 修改了如果只有一张图片的时候不允许轮播。
* 更新至 28/03/2017。 添加了当 CollectionView 的 bounds 发生改变后的处理, 比如说屏幕旋转。
* 更新至 09/02/2017。 添加了自动轮播功能和添加了在纯代码中使用的 Demo ~ 🍻🍻
* 更新至 07/02/2017。 暂只演示了在 Storyboard 中的使用，后续将会补全在纯代码中的使用方法😋

## Any Questions？
Please contact me via Email : 740697612@qq.com

## License
VTAutoSlideView is released under the MIT license. See LICENSE for details.
