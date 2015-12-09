//
//  UIView+Extensions.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2015-09-04.
//

import UIKit

public extension UIView {

	/**
	Directy contaitns a view, not recursively
	
	- parameter view: child view
	
	- returns: true for directly contains, otherwise false
	*/
	public func containSubview(view: UIView) -> Bool {
		if #available(iOS 9.0, *) {
			return subviews.contains(view)
		} else {
			return subviews.filter({$0 == view}).count > 0
		}
	}
	
	public func removeAllSubviews() {
		if #available(iOS 9.0, *) {
			subviews.forEach{ $0.removeFromSuperview() }
		} else {
			for subview in subviews {
				subview.removeFromSuperview()
			}
		}
	}
	
	public func removeAllSubviewsExceptView(view: UIView) {
		if #available(iOS 9.0, *) {
			subviews.filter({$0 != view}).forEach { $0.removeFromSuperview() }
		} else {
			for subview in subviews.filter({$0 != view}) {
				subview.removeFromSuperview()
			}
		}
	}
	
	public func removeAllSubviewsExceptViews(views: [UIView]) {
		if #available(iOS 9.0, *) {
			subviews.filter({ views.contains($0) }).forEach { $0.removeFromSuperview() }
		} else {
			for subview in subviews.filter({ views.contains($0) }) {
				subview.removeFromSuperview()
			}
		}
	}
}

public extension UIView {
	public func frameRectInView(view: UIView?) -> CGRect {
		return self.convertRect(self.bounds, toView: view)
	}
}

// MARK: - Auto Layout
public extension UIView {
	
	public func fullSizeInSuperview() {
		guard let superview = self.superview else {
			fatalError("superview is nil")
		}
		
		translatesAutoresizingMaskIntoConstraints = false
		
		if #available(iOS 9.0, *) {
		    self.topAnchor.constraintEqualToAnchor(superview.topAnchor).active = true
			self.leadingAnchor.constraintEqualToAnchor(superview.leadingAnchor).active = true
			self.bottomAnchor.constraintEqualToAnchor(superview.bottomAnchor).active = true
			self.trailingAnchor.constraintEqualToAnchor(superview.trailingAnchor).active = true
		} else {
			NSLayoutConstraint(item: self, attribute: .Top, relatedBy: .Equal, toItem: superview, attribute: .Top, multiplier: 1.0, constant: 0.0).active = true
			NSLayoutConstraint(item: self, attribute: .Leading, relatedBy: .Equal, toItem: superview, attribute: .Leading, multiplier: 1.0, constant: 0.0).active = true
			NSLayoutConstraint(item: self, attribute: .Bottom, relatedBy: .Equal, toItem: superview, attribute: .Bottom, multiplier: 1.0, constant: 0.0).active = true
			NSLayoutConstraint(item: self, attribute: .Trailing, relatedBy: .Equal, toItem: superview, attribute: .Trailing, multiplier: 1.0, constant: 0.0).active = true
		}
	}
	
	public func fullSizeMarginInSuperview() {
		guard let superview = self.superview else {
			fatalError("superview is nil")
		}
		
		translatesAutoresizingMaskIntoConstraints = false

		NSLayoutConstraint(item: self, attribute: .TopMargin, relatedBy: .Equal, toItem: superview, attribute: .TopMargin, multiplier: 1.0, constant: 0.0).active = true
		NSLayoutConstraint(item: self, attribute: .LeadingMargin, relatedBy: .Equal, toItem: superview, attribute: .LeadingMargin, multiplier: 1.0, constant: 0.0).active = true
		NSLayoutConstraint(item: self, attribute: .BottomMargin, relatedBy: .Equal, toItem: superview, attribute: .BottomMargin, multiplier: 1.0, constant: 0.0).active = true
		NSLayoutConstraint(item: self, attribute: .TrailingMargin, relatedBy: .Equal, toItem: superview, attribute: .TrailingMargin, multiplier: 1.0, constant: 0.0).active = true
	}
	
	public func centerInSuperview() {
		guard let superview = self.superview else {
			fatalError("superview is nil")
		}
		
		translatesAutoresizingMaskIntoConstraints = false
		
		if #available(iOS 9.0, *) {
			self.centerXAnchor.constraintEqualToAnchor(superview.centerXAnchor).active = true
			self.centerYAnchor.constraintEqualToAnchor(superview.centerYAnchor).active = true
		} else {
			NSLayoutConstraint(item: self, attribute: .CenterX, relatedBy: .Equal, toItem: superview, attribute: .CenterX, multiplier: 1.0, constant: 0.0).active = true
			NSLayoutConstraint(item: self, attribute: .CenterY, relatedBy: .Equal, toItem: superview, attribute: .CenterY, multiplier: 1.0, constant: 0.0).active = true
		}
	}
	
	public func constraintWidth(width: CGFloat) {
		if #available(iOS 9.0, *) {
			self.widthAnchor.constraintEqualToConstant(width).active = true
		} else {
			NSLayoutConstraint(item: self, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: width).active = true
		}
	}
	
	public func constraintHeight(height: CGFloat) {
		if #available(iOS 9.0, *) {
			self.heightAnchor.constraintEqualToConstant(height).active = true
		} else {
			NSLayoutConstraint(item: self, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 0.0, constant: height).active = true
		}
	}
	
	public func constraintToSize(size: CGSize) {
		constraintWidth(size.width)
		constraintHeight(size.height)
	}
}

public extension UIView {
	public var isVisible: Bool { return (window != nil) }
}

public extension UIView {
	public func setHidden(hidden: Bool, animated: Bool = false, duration: NSTimeInterval = 0.25, completion: ((Bool) -> ())? = nil) {
		if !animated {
			alpha = hidden ? 0.0 : 1.0
			self.hidden = hidden
			completion?(true)
		} else {
			// If to visible, set hidden to false first, then animate alpha
			if !hidden {
				self.hidden = hidden
			}
			
			UIView.animateWithDuration(duration, animations: {
				self.alpha = hidden ? 0.0 : 1.0
				}, completion: { (finished) -> Void in
					self.hidden = hidden
					completion?(finished)
			})
		}
	}
}

public extension UIView {
	// MARK: - Overlay View
	private struct zhOverlayViewKey {
		static var Key = "zhOverlayViewKey"
	}
	
	private var zhOverlayView: UIView? {
		get { return objc_getAssociatedObject(self, &zhOverlayViewKey.Key) as? UIView }
		set { objc_setAssociatedObject(self, &zhOverlayViewKey.Key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	public func addOverlayView(animated animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, overlayViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.6), completion: ((Bool) -> ())? = nil) -> UIView {
		return _setupOverlayView({ [unowned self] overlayView in
			self.addSubview(overlayView)
			}, animated: animated, duration: duration, delay: delay, dampingRatio: dampingRatio, velocity: velocity, overlayViewBackgroundColor: overlayViewBackgroundColor, completion: completion)
	}
	
	public func insertOverlayViewBelowSubview(belowSubview: UIView, animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, overlayViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.5), completion: ((Bool) -> ())? = nil) -> UIView {
		return _setupOverlayView({ [unowned self] overlayView in
			self.insertSubview(overlayView, belowSubview: belowSubview)
			}, animated: animated, duration: duration, delay: delay, dampingRatio: dampingRatio, velocity: velocity, overlayViewBackgroundColor: overlayViewBackgroundColor, completion: completion)
	}
	
	public func insertOverlayViewAboveSubview(aboveSubview: UIView, animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, overlayViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.5), completion: ((Bool) -> ())? = nil) -> UIView {
		return _setupOverlayView({ [unowned self] overlayView in
			self.insertSubview(overlayView, aboveSubview: aboveSubview)
			}, animated: animated, duration: duration, delay: delay, dampingRatio: dampingRatio, velocity: velocity, overlayViewBackgroundColor: overlayViewBackgroundColor, completion: completion)
	}
	
	private func _setupOverlayView(viewConfiguration: (UIView -> Void), animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, overlayViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.5), completion: ((Bool) -> ())? = nil) -> UIView {
		if zhOverlayView != nil {
			print("warning: found existing overlay view")
		}
		
		let overlayView = UIView()
		overlayView.translatesAutoresizingMaskIntoConstraints = false
		overlayView.backgroundColor = overlayViewBackgroundColor
		
		// Let self keep the reference to the view, used for retriving the overlay view
		zhOverlayView = overlayView
		
		if !animated {
			viewConfiguration(overlayView)
			overlayView.fullSizeInSuperview()
			completion?(true)
		} else {
			overlayView.alpha = 0.0
			viewConfiguration(overlayView)
			overlayView.fullSizeInSuperview()
			UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [.CurveEaseInOut, .BeginFromCurrentState] , animations: {
				overlayView.alpha = 1.0
				}) { (finished) -> Void in
					completion?(finished)
			}
		}
		
		return overlayView
	}
	
	public func removeOverlayView(animated animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, completion: ((Bool) -> ())? = nil) {
		guard let overlayView = zhOverlayView else {
			print("error: overlay view is not existed")
			completion?(false)
			return
		}
		
		if !animated {
			overlayView.removeFromSuperview()
			zhOverlayView = nil
			completion?(true)
			return
		}
		
		UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
			overlayView.alpha = 0.0
			}) { (finished) -> Void in
				overlayView.removeFromSuperview()
				self.zhOverlayView = nil
				completion?(finished)
		}
	}
	
	// MARK: - Blurred Overlay View
	private struct zhBlurredOverlayViewKey {
		static var Key = "zhBlurredOverlayViewKey"
	}
	
	private var zhBlurredOverlayView: UIView? {
		get { return objc_getAssociatedObject(self, &zhBlurredOverlayViewKey.Key) as? UIView }
		set { objc_setAssociatedObject(self, &zhBlurredOverlayViewKey.Key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	public func addBlurredOverlayView(animated animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, blurredViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.5), blurEffectStyle: UIBlurEffectStyle = .Dark, completion: ((Bool) -> ())? = nil) -> UIView {
		return _setupBlurredOverlayView({ [unowned self] overlayView in
			self.addSubview(overlayView)
			}, animated: animated, duration: duration, delay: delay, dampingRatio: dampingRatio, velocity: velocity, blurredViewBackgroundColor: blurredViewBackgroundColor, blurEffectStyle: blurEffectStyle, completion: completion)
	}
	
	public func insertBlurredOverlayViewBelowSubview(belowSubview: UIView, animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, blurredViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.5), blurEffectStyle: UIBlurEffectStyle = .Dark, completion: ((Bool) -> ())? = nil) -> UIView {
		return _setupBlurredOverlayView({ [unowned self] overlayView in
			self.insertSubview(overlayView, belowSubview: belowSubview)
			}, animated: animated, duration: duration, delay: delay, dampingRatio: dampingRatio, velocity: velocity, blurredViewBackgroundColor: blurredViewBackgroundColor, blurEffectStyle: blurEffectStyle, completion: completion)
	}
	
	public func insertBlurredOverlayViewAboveSubview(aboveSubview: UIView, animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, blurredViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.5), blurEffectStyle: UIBlurEffectStyle = .Dark, completion: ((Bool) -> ())? = nil) -> UIView {
		return _setupBlurredOverlayView({ [unowned self] overlayView in
			self.insertSubview(overlayView, aboveSubview: aboveSubview)
			}, animated: animated, duration: duration, delay: delay, dampingRatio: dampingRatio, velocity: velocity, blurredViewBackgroundColor: blurredViewBackgroundColor, blurEffectStyle: blurEffectStyle, completion: completion)
	}
	
	private func _setupBlurredOverlayView(viewConfiguration: (UIView -> Void), animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, blurredViewBackgroundColor: UIColor = UIColor(white: 0.0, alpha: 0.5), blurEffectStyle: UIBlurEffectStyle = .Dark, completion: ((Bool) -> ())? = nil) -> UIView {
		if zhBlurredOverlayView != nil {
			print("warning: found existing blurred overlay view")
		}
		
		let overlayView = UIVisualEffectView(effect: UIBlurEffect(style: blurEffectStyle))
		overlayView.translatesAutoresizingMaskIntoConstraints = false
		overlayView.backgroundColor = blurredViewBackgroundColor
		
		// Let self keep the reference to the view, used for retriving the overlay view
		zhBlurredOverlayView = overlayView
		
		if !animated {
			viewConfiguration(overlayView)
			overlayView.fullSizeInSuperview()
			completion?(true)
		} else {
			overlayView.alpha = 0.0
			viewConfiguration(overlayView)
			overlayView.fullSizeInSuperview()
			UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [.CurveEaseInOut, .BeginFromCurrentState] , animations: {
				overlayView.alpha = 1.0
				}) { (finished) -> Void in
					completion?(finished)
			}
		}
		
		return overlayView
	}
	
	public func removeBlurredOverlayView(animated animated: Bool = true, duration: NSTimeInterval = 0.5, delay: NSTimeInterval = 0.0, dampingRatio: CGFloat = 1.0, velocity: CGFloat = 1.0, completion: ((Bool) -> ())? = nil) {
		guard let overlayView = zhBlurredOverlayView else {
			print("error: blurred overlay view is not existed")
			completion?(false)
			return
		}
		
		if !animated {
			overlayView.removeFromSuperview()
			zhBlurredOverlayView = nil
			completion?(true)
		} else {
			UIView.animateWithDuration(duration, delay: delay, usingSpringWithDamping: dampingRatio, initialSpringVelocity: velocity, options: [.CurveEaseInOut, .BeginFromCurrentState], animations: {
				overlayView.alpha = 0.0
				}) { (finished) -> Void in
					overlayView.removeFromSuperview()
					self.zhBlurredOverlayView = nil
					completion?(finished)
			}
		}
	}
}



// MARK: - addGestureRecognizer Swizzling
public extension UIView {
	// Swizzling addGestureRecognizer(_: UIGestureRecognizer)
	public override class func initialize() {
		struct Static {
			static var addGestureRecognizerToken: dispatch_once_t = 0
		}
		
		// make sure this isn't a subclass
		if self !== UIView.self {
			return
		}
		
		dispatch_once(&Static.addGestureRecognizerToken) {
			let originalSelector = Selector("addGestureRecognizer:")
			let swizzledSelector = Selector("zhh_addGestureRecognizer:")
			
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
	
	func zhh_addGestureRecognizer(gestureRecognizer: UIGestureRecognizer) {
		self.zhh_addGestureRecognizer(gestureRecognizer)
		gestureRecognizer.attachedView = self
		
		if let longPressGesture = gestureRecognizer as? UILongPressGestureRecognizer {
			longPressGesture.setupForDetectingVelocity()
		}
	}
}



// MARK: - Utility
public extension UIView {
	/**
	Get the view controller presenting this view
	
	- returns: the view controller for presenting this view or nil
	*/
	public func firstRespondedViewController() -> UIViewController? {
		if let viewController = nextResponder() as? UIViewController {
			return viewController
		} else if let view = nextResponder() as? UIView {
			return view.firstRespondedViewController()
		} else {
			return nil
		}
	}
	
	/// Get the view controller presenting this view
	public var presentingViewController: UIViewController? {
		return firstRespondedViewController()
	}
}


public extension UIView {
	public func viewCopy() -> UIView {
		let data: NSData = NSKeyedArchiver.archivedDataWithRootObject(self)
		let copy = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! UIView
		return copy
	}
}
