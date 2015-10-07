//
//  PgaeViewController.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-10-05.
//
//

import UIKit

public class PageViewController : UIViewController {
	// MARK: - Public
	public var selectedIndex: Int = 0 {
		didSet {
			// TODO: SetSelectedIndex animated
		}
	}
	public var selectedViewController: UIViewController {
		return viewControllers[selectedIndex]
	}
	
	public var viewControllers = [UIViewController]() {
		willSet {
			willReplaceOldViewControllers(viewControllers, withNewViewControllers: newValue)
			setupChildViewControllerViews(newValue)
		}
		didSet {
			didReplaceOldViewControllers(oldValue, withNewViewControllers: viewControllers)
		}
	}
	
	// MARK: - Private
	// MARK: - Getting forward/backward view controllers
	private var forwardViewController: UIViewController? {
		return (selectedIndex + 1 < viewControllers.count) ? viewControllers[selectedIndex + 1] : nil
	}
	
	private var backwardViewController: UIViewController? {
		return selectedIndex - 1 >= 0 ? viewControllers[selectedIndex - 1] : nil
	}
	
	// MARK: - Dragging related
	private var isDragging: Bool = false
	private var beginDraggingContentOffsetX: CGFloat = 0.0 {
		didSet {
			// Round off begin content offset x
			beginDraggingContentOffsetX = CGFloat(Int(beginDraggingContentOffsetX) / Int(view.bounds.width)) * view.bounds.width
		}
	}
	private var willEndDraggingTargetContentOffsetX: CGFloat = 0.0
	
	private var draggingOffsetX: CGFloat { return pageScrollView.contentOffset.x - beginDraggingContentOffsetX }
	private var draggingForward: Bool? {
		if draggingOffsetX == 0 {
			return nil
		} else {
			return draggingOffsetX > 0
		}
	}
	
	// MARK: - Properties
	private let pageScrollView = UIScrollView()
	
	// MARK: - Override
	public override func shouldAutomaticallyForwardAppearanceMethods() -> Bool {
		return false
	}
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		setupViews()
	}
	
	private func setupViews() {
		view.addSubview(pageScrollView)
		pageScrollView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
		pageScrollView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
		pageScrollView.delegate = self
		
		pageScrollView.pagingEnabled = true
		pageScrollView.scrollEnabled = true
		pageScrollView.bounces = true
		pageScrollView.alwaysBounceHorizontal = true
		pageScrollView.alwaysBounceVertical = false
		pageScrollView.directionalLockEnabled = true
		pageScrollView.scrollsToTop = false
		pageScrollView.showsHorizontalScrollIndicator = false
		pageScrollView.showsVerticalScrollIndicator = false
		
		// TODO: Those two proerties need to be tested
		pageScrollView.delaysContentTouches = false
		pageScrollView.canCancelContentTouches = true
		
		pageScrollView.contentInset = UIEdgeInsetsZero
		automaticallyAdjustsScrollViewInsets = false
	}
	
	public override func viewWillAppear(animated: Bool) {
		super.viewWillAppear(animated)
		selectedViewController.beginAppearanceTransition(true, animated: animated)
	}
	
	public override func viewDidAppear(animated: Bool) {
		super.viewDidAppear(animated)
		selectedViewController.endAppearanceTransition()
	}
	
	public override func viewWillDisappear(animated: Bool) {
		super.viewWillDisappear(animated)
		selectedViewController.beginAppearanceTransition(false, animated: animated)
	}
	
	public override func viewDidDisappear(animated: Bool) {
		super.viewDidDisappear(animated)
		selectedViewController.endAppearanceTransition()
	}
	
	private func willReplaceOldViewControllers(oldViewControllers: [UIViewController], withNewViewControllers newViewControllers: [UIViewController]) {
		for viewController in oldViewControllers {
			removeViewController(viewController)
		}
		
		for viewController in newViewControllers {
			addViewController(viewController)
		}
	}
	
	private func didReplaceOldViewControllers(oldViewControllers: [UIViewController], withNewViewControllers newViewControllers: [UIViewController]) {
		//
	}
	
	private func setupChildViewControllerViews(viewControllers: [UIViewController]) {
		// TODO: layoutSubviews may need to update contentSize
		pageScrollView.contentSize = CGSize(width: view.bounds.width * CGFloat(viewControllers.count), height: view.bounds.height)
		for (index, viewController) in viewControllers.enumerate() {
			viewController.view.frame = CGRect(x: CGFloat(index) * view.bounds.width, y: 0, width: view.bounds.width, height: view.bounds.height)
		}
	}
}

extension PageViewController {
	private func removeViewController(viewController: UIViewController) {
		viewController.willMoveToParentViewController(nil)
		viewController.view.removeFromSuperview()
		viewController.removeFromParentViewController()
	}
	
	private func addViewController(viewController: UIViewController) {
		addChildViewController(viewController)
		pageScrollView.addSubview(viewController.view)
		viewController.didMoveToParentViewController(self)
	}
}

// MARK: - UIScrollViewDelegate
extension PageViewController : UIScrollViewDelegate {
	public func scrollViewDidScroll(scrollView: UIScrollView) {
		// Disable vertical scrolling
		if scrollView.contentOffset.y != 0 {
			scrollView.contentOffset = CGPoint(x: scrollView.contentOffset.x, y: 0)
		}
		
		if !isDragging {
			let willSelectedIndex = Int(willEndDraggingTargetContentOffsetX) / Int(view.bounds.width)
			let willSelectedViewController = viewControllers[willSelectedIndex]
			
			// If current appearing view controller is not will selected view controller, state is mismatched. End it's transition
			let appearingViewControllers = viewControllers.filter { $0.isAppearing == true }
			assert(appearingViewControllers.count <= 1)
			if let willAppearViewController = appearingViewControllers.first where willAppearViewController !== willSelectedViewController {
				willAppearViewController.endAppearanceTransition()
			}
			
			// If the view controller moving to appearance call is not called, call it
			if willSelectedViewController.isAppearing == nil {
				willSelectedViewController.beginAppearanceTransition(true, animated: true)
			}
			
			// If selected view controller disappearing call is not called, call it
			if selectedViewController.isAppearing == nil {
				selectedViewController.beginAppearanceTransition(false, animated: true)
			}
			
			return
		}
		
		// Dragging Zero offset
		guard let draggingForward = draggingForward else {
			if forwardViewController?.isAppearing != nil {
				forwardViewController?.beginAppearanceTransition(false, animated: false)
				forwardViewController?.endAppearanceTransition()
			}
			
			if backwardViewController?.isAppearing != nil {
				backwardViewController?.beginAppearanceTransition(false, animated: false)
				backwardViewController?.endAppearanceTransition()
			}
			
			return
		}
		
		selectedViewController.beginAppearanceTransition(false, animated: true)
		
		if draggingForward {
			if backwardViewController?.isAppearing != nil {
				backwardViewController?.beginAppearanceTransition(false, animated: false)
				backwardViewController?.endAppearanceTransition()
			}
			
			forwardViewController?.beginAppearanceTransition(true, animated: true)
		} else {
			if forwardViewController?.isAppearing != nil {
				forwardViewController?.beginAppearanceTransition(false, animated: false)
				forwardViewController?.endAppearanceTransition()
			}
			
			backwardViewController?.beginAppearanceTransition(true, animated: true)
		}
	}
	
	public func scrollViewWillBeginDragging(scrollView: UIScrollView) {
		// If when new dragging initiatied, last dragging is still in progress.
		// End appearance transition immediately
		// And set selectedIndex to willAppear view controller
		let appearingViewControllers = viewControllers.filter { $0.isAppearing == true }
		assert(appearingViewControllers.count <= 1)
		viewControllers.filter { $0.isAppearing != nil }.forEach { $0.endAppearanceTransition() }
		
		if let willAppearViewController = appearingViewControllers.first {
			selectedIndex = viewControllers.indexOf(willAppearViewController)!
		}
		
		isDragging = true
		beginDraggingContentOffsetX = scrollView.contentOffset.x
	}
	
	public func scrollViewWillEndDragging(scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
		isDragging = false
		willEndDraggingTargetContentOffsetX = targetContentOffset.memory.x
		if willEndDraggingTargetContentOffsetX == beginDraggingContentOffsetX {
			// If will end equals begin dragging content offset x,
			// which means dragging cancels
			selectedViewController.beginAppearanceTransition(true, animated: true)
			
			if forwardViewController?.isAppearing != nil {
				forwardViewController?.beginAppearanceTransition(false, animated: true)
			}
			
			if backwardViewController?.isAppearing != nil {
				backwardViewController?.beginAppearanceTransition(false, animated: true)
			}
		}
	}
	
	public func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
		// If dragging ends at separator point, clean state
		if scrollView.contentOffset.x % view.bounds.width == 0 {
			viewControllers.filter { $0.isAppearing != nil }.forEach { $0.endAppearanceTransition() }
			selectedIndex = Int(scrollView.contentOffset.x) / Int(view.bounds.width)
			assert(viewControllers.filter { $0.isAppearing != nil }.count == 0)
		}
	}
	
	public func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
		// If for some reasons, scrollView.contentOffset.x is not matched with willEndDraggingTargetContentOffset
		// End current transitions
		// Add missing transitions
		if willEndDraggingTargetContentOffsetX != scrollView.contentOffset.x {
			let appearingViewControllers = viewControllers.filter { $0.isAppearing == true }
			assert(appearingViewControllers.count <= 1)
			
			// End current transitions
			viewControllers.filter { $0.isAppearing != nil }.forEach { $0.endAppearanceTransition() }
			
			if let willAppearViewController = appearingViewControllers.first {
				selectedIndex = viewControllers.indexOf(willAppearViewController)!
				
				// Add missing transitions
				selectedViewController.beginAppearanceTransition(false, animated: false)
				selectedViewController.endAppearanceTransition()
				
				let willSelectedIndex = Int(scrollView.contentOffset.x) / Int(view.bounds.width)
				let willSelectedViewController = viewControllers[willSelectedIndex]
				willSelectedViewController.beginAppearanceTransition(true, animated: false)
				willSelectedViewController.endAppearanceTransition()
				selectedIndex = willSelectedIndex
			}
		} else {
			viewControllers.filter { $0.isAppearing != nil }.forEach { $0.endAppearanceTransition() }
			selectedIndex = Int(scrollView.contentOffset.x) / Int(view.bounds.width)
		}
		
		assert(viewControllers.filter { $0.isAppearing != nil }.count == 0)
	}
}

extension UIViewController {
	// AppearanceState Associated Property
	enum AppearanceState {
		case WillAppear
		case WillDisappear
	}
	
	private struct AssociatedKeys {
		static var AppearanceStateKey = "zhh_AppearanceStateKey"
	}
	
	var isAppearing: Bool? {
		get {
			return objc_getAssociatedObject(self, &AssociatedKeys.AppearanceStateKey) as? Bool
		}
		
		set {
			objc_setAssociatedObject(self, &AssociatedKeys.AppearanceStateKey, newValue as Bool? as? AnyObject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	// Swizzling beginAppearanceTransition/endAppearanceTransition
	public override class func initialize() {
		struct Static {
			static var beginAppearanceTransitionToken: dispatch_once_t = 0
			static var endAppearanceTransitionToken: dispatch_once_t = 0
		}
		
		// make sure this isn't a subclass
		if self !== UIViewController.self {
			return
		}
		
		dispatch_once(&Static.beginAppearanceTransitionToken) {
			let originalSelector = Selector("beginAppearanceTransition:animated:")
			let swizzledSelector = Selector("zhh_beginAppearanceTransition:animated:")
			
			let originalMethod = class_getInstanceMethod(self, originalSelector)
			let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
			
			let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
			
			if didAddMethod {
				class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
			} else {
				method_exchangeImplementations(originalMethod, swizzledMethod);
			}
		}
		
		dispatch_once(&Static.endAppearanceTransitionToken) {
			let originalSelector = Selector("endAppearanceTransition")
			let swizzledSelector = Selector("zhh_endAppearanceTransition")
			
			let originalMethod = class_getInstanceMethod(self, originalSelector)
			let swizzledMethod = class_getInstanceMethod(self, swizzledSelector)
			
			let didAddMethod = class_addMethod(self, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))
			
			if didAddMethod {
				class_replaceMethod(self, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
			} else {
				method_exchangeImplementations(originalMethod, swizzledMethod);
			}
		}
	}
	
	func zhh_beginAppearanceTransition(isAppearing: Bool, animated: Bool) {
		if self.isAppearing != isAppearing {
			self.zhh_beginAppearanceTransition(isAppearing, animated: animated)
			self.isAppearing = isAppearing
		}
	}
	
	func zhh_endAppearanceTransition() {
		self.zhh_endAppearanceTransition()
		self.isAppearing = nil
	}
}
