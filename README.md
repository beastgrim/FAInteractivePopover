[![Platform](https://img.shields.io/cocoapods/p/FloatingPanel.svg)](https://cocoapods.org/pods/FloatingPanel)
[![Swift 4.2](https://img.shields.io/badge/Swift-4.2-orange.svg?style=flat)](https://swift.org/)

#  FAInteractivePopover

An transitioning delegate for presenting and dismissing view controllers like AppleMusic player popover.

![Preview](https://github.com/beastgrim/FAPopoverInteractiveTransition/raw/master/Resources/Preview.gif)


## Usage

#### Presenting popover

```swift

class ViewController: UIViewController {
    
    lazy private var interactivePresentor = FAPopoverInteractiveTransition()
    
    @objc func show(_ sender: Any?) {
        let popover = PopoverViewController()
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
        // If needed
        self.interactivePresentor?.delegate = self
    }
}
```

#### Animating pull down view

```swift

extension PopoverViewController: FAPopoverInteractiveTransitionDelegate {
    
    func popoverInteractiveTransitionDidEndInteractive(_ interactiveTransition: FAPopoverInteractiveTransition) {
        self.pullDownView?.active = true
    }
    
    func popoverInteractiveTransition(_ interactiveTransition: FAPopoverInteractiveTransition, didChangeFractionCompleted fractionCompleted: CGFloat) {
        let active = !interactiveTransition.isInteractiveTransitionStarted || fractionCompleted == 0 || fractionCompleted == 1.0
        self.pullDownView?.active = active
    }
}
```


## Author

Evgeny Bogomolov <beastgrim@gmail.com>

## License

FAInteractivePopover is available under the MIT license. See the LICENSE file for more info.
