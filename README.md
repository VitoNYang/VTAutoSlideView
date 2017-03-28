# VTAutoSlideView
![Version](https://img.shields.io/cocoapods/v/VTAutoSlideView.svg?style=flat)
![Version](https://img.shields.io/cocoapods/p/VTAutoSlideView.svg?style=flat)
[![Version](https://img.shields.io/cocoapods/l/VTAutoSlideView.svg?style=flat)](https://github.com/VitoNYang/VTAutoSlideView/blob/master/LICENSE)

### 无论是在新闻 APP、商城 APP、音乐APP还是社交 APP，我们经常能看到一种视图——无限循环滚动视图😆。
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
####Storyboard / Xib (用Storyboard 或者 Xib创建现仅支持横向轮播)

1. 在 Storyboard 或 Xib 中拉一个 View， 设置改 View 为 VTAutoSlideView
2. 创建一个 UICollectionViewCell，并设置自己的布局
3. 在 ViewController 注册你的 Cell, 并设置 VTAutoSlideView 的 `dataSource` 和 `dataList`

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
4. 实现 VTAutoSlideViewDataSource 的 configuration(cell:for) 方法，配置你的 cell

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
5.  现在你可以 Run 你的项目了，如果一切都没有设置错的话，应该就可以成功的跑起来了🍻🍻

###Code
1. 创建 VTAutoSlideView，设置横向还是纵向，同时设置`dataSource`
`let slideView = VTAutoSlideView(direction: .vertical, dataSource: self)`
2. 注册 Cell，设置 dataList

	``` swift
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
	```
3. 实现 VTAutoSlideViewDataSource 的 configuration(cell:for) 方法，配置你的 cell (参考 Storyboard / Xib 中的代码)
4. 没有配置错的话，一切也已经可以正常运行起来了。
 
## Demo
* 更新自 28/03/2017。 添加了当 CollectionView 的 bounds 发生改变后的处理, 比如说屏幕旋转。
* 更新自 09/02/2017。 添加了自动轮播功能和添加了在纯代码中使用的 Demo ~ 🍻🍻
* 更新自 07/02/2017。 暂只演示了在 Storyboard 中的使用，后续将会补全在纯代码中的使用方法😋

## 有问题？
请联系我 Email : 740697612@qq.com

## License
VTAutoSlideView is released under the MIT license. See LICENSE for details.