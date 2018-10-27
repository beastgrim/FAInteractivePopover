[![Platform](https://img.shields.io/cocoapods/p/FloatingPanel.svg)](https://cocoapods.org/pods/FloatingPanel)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://swift.org/)

#  FAPopoverInteractiveTransition

	An transitioning delegate for presenting and dismissing view controllers like AppleMusic player popover.

![Maps](https://github.com/beastgrim/FAPopoverInteractiveTransition/tree/master/Resources/Preview.gif)


## Usage

#### Presenting popover

```swift

class ViewController: UIViewController {
    
    lazy private var interactivePresentor = FAPopoverInteractiveTransition()
    
    @objc func show(_ sender: Any?) {
        let popover = PopoverViewController()
        popover.title = "Popover"
        popover.modalPresentationStyle = .custom
        popover.transitioningDelegate = self.interactivePresentor
        
        self.present(popover, animated: true, completion: nil)
    }
}
```

#### If your popover has scroll view for interaction

```swift

class PopoverViewController: UIViewController {

    weak var interactivePresentor: FAPopoverInteractiveTransition?
    
    var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.scrollView = UIScrollView()
        //...
        // Enable dismiss interaction by your an scroll view
        self.interactivePresentor?.scrollView = self.scrollView
    }
}
```

