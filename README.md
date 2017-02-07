# VTAutoSlideView
[![Version](https://img.shields.io/cocoapods/v/VTAutoSlideView.svg?style=flat)]()
[![Version](https://img.shields.io/cocoapods/l/VTAutoSlideView.svg?style=flat)]()
[![Version](https://img.shields.io/cocoapods/p/VTAutoSlideView.svg?style=flat)]()
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
### 无论是在新闻APP、商城APP、音乐APP还是社交APP，我们经常能看到一种视图——无限循环滚动视图😆。
####这类视图通常用来展示照片、新闻、商品，常用度相信不用我再做过多阐述了🙂。所以这也是 *VTAutoSlideView* 产生的原因，接下来让我们看看怎么使用吧😊

## 要求
- iOS 9.0+
- Xcode 8.0+
- Swift 3.0+


## 安装
####CocoaPods
- 添加 `pod 'VTAutoSlideView'` 到你的 Podfile中.
- 运行 `pod install` 或者 `pod update`

## 快速上手
####Storyboard / Xib

1. 在Storyboard 或 Xib中拉一个View， 设置改View 为VTAutoSlideView
2. 创建一个UICollectionViewCell，并设置自己的布局
3. 在ViewController注册你的Cell, 并设置VTAutoSlideView的 `dataSource` 和 `dataList`

 	``` swift
	@IBOutlet weak var slideView: VTAutoSlideView!
	    
	// 你的数据源
	lazy var imageList = {
	    (1...4).map{ "0\($0)" }.map{ UIImage(named: $0) }.filter{ $0 != nil }.map{ $0! }
	}()
	
	override func viewDidLoad() {
	    super.viewDidLoad()
	    // 先注册你的 CollectionViewCell
	    // 如果是Xib创建的用下面这个方法注册
	    slideView.register(nib: UINib(nibName: "DisplayImageCell", bundle: nibBundle))
	    // 或者如果是用代码创建的，用下面这个方法注册
	    //slideView.register(cellClass: DisplayImageCell.self)
	    slideView.dataSource = self
	    slideView.dataList = imageList
	}
	```
4. 实现VTAutoSlideViewDataSource 的 configuration(cell:for) 方法，配置你的 cell

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
5.  现在你可以Run 你的项目了，如果一切都没有设置错的话，应该就可以成功的跑起来了🍻🍻
	 
	 
## Demo
* 更新自 07/02/2017。 暂只演示了在Storyboard 中的使用，后续将会补全在纯代码中的使用方法😋


## License
VTAutoSlideView is released under the MIT license. See LICENSE for details.