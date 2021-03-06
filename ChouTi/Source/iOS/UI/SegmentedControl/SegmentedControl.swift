//
//  SegmentedControl.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2015-06-16.
//

import UIKit

open class SegmentedControl: UISegmentedControl {
	
	// MARK: - Appearance
	
	/// Override tintColor, super.tintColor will be always clearColor
	/// When titleSelectedColor is nil, tintColor will be used
	fileprivate var _tintColor = UIColor.blue.withAlphaComponent(0.5) {
		didSet {
			titleSelectedColor = _tintColor
			selectedUnderScoreView?.backgroundColor = _tintColor
		}
	}
	/// tintColor will be used for selected underscore bar color and it's a backup color for titleSelectedColor
	override open var tintColor: UIColor! {
		set {
			_tintColor = newValue
		}
		
		get {
			return _tintColor
		}
	}
	
	/// Selected color for item, if this color is nil, tintColor will be used
	open var titleSelectedColor: UIColor? {
		didSet {
			if selectedSegmentIndex >= 0, let color = titleSelectedColor {
				itemLabels[selectedSegmentIndex].textColor = color
			}
		}
	}
	/// Unselected color for item, if this color is nil, border color will be used
	open var titleUnSelectedColor: UIColor? {
		didSet {
			if let color = titleUnSelectedColor {
				for (index, label) in itemLabels.enumerated() {
					if index == selectedSegmentIndex {
						continue
					} else {
						label.textColor = color
					}
				}
			}
		}
	}
	
	open var titleFont: UIFont = UIFont.systemFont(ofSize: 13.0) {
		didSet {
			itemLabels.forEach { $0.font = self.titleFont }
		}
	}
	
	// Selected Under Score Indicator
	open var underScoreHeight: CGFloat = 4.0 {
		didSet {
			if let constraint = underScoreHeightConstraint {
				constraint.constant = underScoreHeight
			}
		}
	}
	
	
	
	// MARK: - Animations Related
	/// true for selection transition animation, false to turn off
	open var shouldBeAnimated: Bool = true
	/// transition animation duration
	open var animationDuration: TimeInterval = 0.2
	
	
	
	// MARK: - Layer Related
	/// Border color for border and separator, default color is light grey
	open var borderColor: UIColor = UIColor(white: 0.0, alpha: 0.10) {
		didSet {
			layer.borderColor = borderColor.cgColor
			itemSeparators.forEach { $0.backgroundColor = self.borderColor }
			if titleUnSelectedColor == nil { titleUnSelectedColor = borderColor }
		}
	}
	
	open var cornerRadius: CGFloat = 0.0 {
		didSet {
			layer.cornerRadius = cornerRadius
		}
	}
	
	fileprivate var borderWidth: CGFloat = 1.0 {
		didSet {
			layer.borderWidth = borderWidth
			layoutMargins = UIEdgeInsets(top: borderWidth, left: borderWidth, bottom: borderWidth, right: borderWidth)
		}
	}
	
	
	
	// MARK: - Privates
	/// titles on the segmented control
	open fileprivate(set) var itemTitles = [String]()
	fileprivate var itemLabels = [UILabel]()
	fileprivate var itemSeparators = [UIView]()
	
	fileprivate var selectedUnderScoreView: UIView!
	/// A flag marks whether the selection is the first time
	fileprivate var previousSelectedIndex: Int = -1
	
	// MARK: - Inner Constraints
	fileprivate var itemConstraints: [NSLayoutConstraint]?
	
	fileprivate var underScoreConstraints: [NSLayoutConstraint]?
	fileprivate var underScoreHeightConstraint: NSLayoutConstraint?
	fileprivate var underScoreLeadingConstraint: NSLayoutConstraint?
	fileprivate var underScoreTrailingConstraint: NSLayoutConstraint?
	
	// MARK: - Init
	/**
	Init with items. Note here, items must be an array of title strings, images segments are not supported yet.
	
	:param: items An array of title strings
	
	:returns: An initalized segmented control
	*/
	public override init(items: [Any]?) {
		super.init(items: items)
		if let titles = items as? [String] {
			setupWithTitles(titles)
		} else {
			fatalError("init with images is not implemented")
		}
	}
	
	public override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	fileprivate func commonInit() {
		// Clear default border color and title color
		super.tintColor = UIColor.clear
		
		self.layer.borderColor = borderColor.cgColor
		self.layer.borderWidth = borderWidth
		self.layer.cornerRadius = cornerRadius
		
		clipsToBounds = true
		
        self.addTarget(self, action: #selector(SegmentedControl.zh_selectedIndexChanged(_:)), for: .valueChanged)
	}
	
	// MARK: - Setup with Titles
	/**
	Setup segmented control with a list of titles, this will removed all previous titles.
	
	:param: titles an array of titles
	*/
	open func setupWithTitles(_ titles: [String]) {
		// If existed titles are same with new titles, return
		if itemTitles == titles {
			return
		}
		
		// new titles are different, reset
		super.removeAllSegments()
		for (index, title) in titles.enumerated() {
			super.insertSegment(withTitle: title, at: index, animated: false)
		}
		
		setupItemsWithTitles(titles)
		setupUnderScoreView()
		
		setupItemConstraints()
		setupUnderScoreViewConstraints()
	}
	
	// MARK: - Setup Views
	/**
	Setup title labels and separators. This will clear all previous title labels and separators and setup new ones.
	
	:param: titles title strings
	*/
	fileprivate func setupItemsWithTitles(_ titles: [String]) {
		itemLabels.forEach { $0.removeFromSuperview() }
		itemSeparators.forEach { $0.removeFromSuperview() }
		
		itemTitles = titles
		itemLabels = []
		itemSeparators = []

		let titlesCount = titles.count
		for (index, title) in titles.enumerated() {
			let label = itemLabelWithTitle(title)
			self.addSubview(label)
			itemLabels.append(label)
			
			if titlesCount > 1 && index < titlesCount {
				let separator = itemSeparatorView()
				self.addSubview(separator)
				itemSeparators.append(separator)
			}
		}
	}
	
	/**
	Setup under score bar view, which is a hightlight bottom bar for selected title
	*/
	fileprivate func setupUnderScoreView() {
		if selectedUnderScoreView == nil {
			selectedUnderScoreView = UIView()
			selectedUnderScoreView.translatesAutoresizingMaskIntoConstraints = false
			selectedUnderScoreView.backgroundColor = titleSelectedColor ?? tintColor
			self.addSubview(selectedUnderScoreView)
		}
	}
	
	// MARK: - Setup Layout
	/**
	Setup constraints for title labels and separators. It chains labels and separators from leading to trailing
	*/
	fileprivate func setupItemConstraints() {
		// Consider borderWidth in layout margins, this will let under score bar align to border correctly
		layoutMargins = UIEdgeInsets(top: borderWidth, left: borderWidth, bottom: borderWidth, right: borderWidth)
		
		if itemConstraints != nil {
			NSLayoutConstraint.deactivate(itemConstraints!)
		}
		
		itemConstraints = [NSLayoutConstraint]()
		
		// Check titles count after cleaning itemConstraints
		let titlesCount = itemLabels.count
		if titlesCount == 0 {
			return
		}
		
		if titlesCount == 1 {
			let views = ["label": itemLabels[0]]
			itemConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "|[label]|", options: [], metrics: nil, views: views)
			itemConstraints! += NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: views)
		} else {
			for (index, label) in itemLabels.enumerated() {
				if index == 0 {
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leadingMargin, multiplier: 1.0, constant: 0.0))
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
				} else {
					let lastIndex = index - 1
					let previousLabel = itemLabels[lastIndex]
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .leading, relatedBy: .equal, toItem: previousLabel, attribute: .trailing, multiplier: 1.0, constant: borderWidth))
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .width, relatedBy: .equal, toItem: previousLabel, attribute: .width, multiplier: 1.0, constant: 0.0))
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .centerY, relatedBy: .equal, toItem: previousLabel, attribute: .centerY, multiplier: 1.0, constant: 0.0))
					
					// Separator
					let separator = itemSeparators[lastIndex]
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: NSLayoutAttribute.leading, relatedBy: .equal, toItem: separator, attribute: .trailing, multiplier: 1.0, constant: 0.0))
					itemConstraints!.append(NSLayoutConstraint(item: separator, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: borderWidth))
					itemConstraints!.append(NSLayoutConstraint(item: separator, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
					itemConstraints!.append(NSLayoutConstraint(item: separator, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
				}
				
				if index == titlesCount - 1 {
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailingMargin, multiplier: 1.0, constant: 0.0))
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1.0, constant: 0.0))
					itemConstraints!.append(NSLayoutConstraint(item: label, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
				}
			}
		}
		
		NSLayoutConstraint.activate(itemConstraints!)
	}
	
	/**
	Setup constraints for under score bar view. By default, it's height is zero.
	*/
	fileprivate func setupUnderScoreViewConstraints() {
		if underScoreConstraints != nil {
			NSLayoutConstraint.deactivate(underScoreConstraints!)
		}
		
		underScoreConstraints = [NSLayoutConstraint]()
		
		// If there's no items, don't setup constraints
		if itemLabels.count == 0 {
			return
		}
		
		underScoreHeightConstraint = NSLayoutConstraint(item: selectedUnderScoreView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: 0.0)
		underScoreConstraints!.append(underScoreHeightConstraint!)
		
		underScoreLeadingConstraint = NSLayoutConstraint(item: selectedUnderScoreView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)
		underScoreConstraints!.append(underScoreLeadingConstraint!)
		
		underScoreTrailingConstraint = NSLayoutConstraint(item: selectedUnderScoreView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)
		underScoreConstraints!.append(underScoreTrailingConstraint!)
		
		underScoreConstraints!.append(NSLayoutConstraint(item: selectedUnderScoreView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0))
		
		NSLayoutConstraint.activate(underScoreConstraints!)
	}
	
	
	
	// MARK: - Overridden
	open override func removeTarget(_ target: Any?, action: Selector?, for controlEvents: UIControlEvents) {
		super.removeTarget(target, action: action, for: controlEvents)
		
		// If trying to remove all targets, add self as target back again
		if target == nil {
            self.addTarget(self, action: #selector(SegmentedControl.zh_selectedIndexChanged(_:)), for: .valueChanged)
		}
	}
	
	// MARK: - Managing Segment Control
	open override func setImage(_ image: UIImage?, forSegmentAt segment: Int) {
		fatalError("Image segment control is not supported yet")
	}
	
	open override func imageForSegment(at segment: Int) -> UIImage? {
		fatalError("Image segment control is not supported yet")
	}
	
	open override func setTitle(_ title: String?, forSegmentAt segment: Int) {
		precondition(segment < itemTitles.count, "segment index out of range")
		if let titleText = title {
			super.setTitle(titleText, forSegmentAt: segment)
			itemTitles[segment] = titleText
			itemLabels[segment].text = titleText
		}
	}
	
	open override func titleForSegment(at segment: Int) -> String? {
		precondition(segment < itemTitles.count, "segment index out of range")
		return itemTitles[segment]
	}
	
	// MARK: - Managing Segments
	open override func insertSegment(with image: UIImage?, at segment: Int, animated: Bool) {
		fatalError("Image segment control is not supported yet")
	}
	
	open override func insertSegment(withTitle title: String!, at segment: Int, animated: Bool) {
		fatalError("Not implemented")
	}
	
	open override var numberOfSegments: Int {
		return itemTitles.count
	}
	
	open override func removeAllSegments() {
		setupWithTitles([])
	}
	
	open override func removeSegment(at segment: Int, animated: Bool) {
		fatalError("Not implemented")
	}
	
	open override var selectedSegmentIndex: Int {
		didSet {
			updateSelectedIndex(selectedSegmentIndex)
			previousSelectedIndex = selectedSegmentIndex
		}
	}
	
	// MARK: - Managing Segment Behavior and Appearance
	open override var isMomentary: Bool {
		didSet {
			fatalError("Not implemented")
		}
	}
	
	open override func setEnabled(_ enabled: Bool, forSegmentAt segment: Int) {
		super.setEnabled(enabled, forSegmentAt: segment)
		precondition(segment < itemTitles.count, "segment is out of range")
		itemLabels[segment].isEnabled = false
	}
	
	open override func isEnabledForSegment(at segment: Int) -> Bool {
		return super.isEnabledForSegment(at: segment)
	}
	
	open override func setContentOffset(_ offset: CGSize, forSegmentAt segment: Int) {
		fatalError("Not implemented")
	}
	
	open override func contentOffsetForSegment(at segment: Int) -> CGSize {
		fatalError("Not implemented")
	}
	
	open override func setWidth(_ width: CGFloat, forSegmentAt segment: Int) {
		fatalError("Not implemented")
	}
	
	open override func widthForSegment(at segment: Int) -> CGFloat {
		fatalError("Not implemented")
	}
	
	open override var apportionsSegmentWidthsByContent: Bool {
		didSet {
			fatalError("Not implemented")
		}
	}
}

// MARK: - Helper
extension SegmentedControl {
	// Creators
	/**
	Create a title label, common setups.
	
	:param: title title string
	
	:returns: a new UILabel instance
	*/
	fileprivate func itemLabelWithTitle(_ title: String) -> UILabel {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		
		label.text = title
		label.textAlignment = .center
		label.font = titleFont
		label.textColor = titleUnSelectedColor ?? borderColor
		
		return label
	}
	
	/**
	Create a separator line view
	
	:returns: a new UIView instance
	*/
	fileprivate func itemSeparatorView() -> UIView {
		let separator = UIView()
		separator.translatesAutoresizingMaskIntoConstraints = false
		
		separator.backgroundColor = borderColor
		
		return separator
	}
	
	/**
	Add a fade in/out transition animation for UILabel
	
	:param: label label that needs a fade in/out animation
	*/
	fileprivate func addFadeTransitionAnimationForLabel(_ label: UILabel?) {
		let textAnimation = CATransition()
		textAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
		textAnimation.type = kCATransitionFade
		textAnimation.duration = shouldBeAnimated ? animationDuration : 0.0
		
		label?.layer.add(textAnimation, forKey: "TextFadeAnimation")
	}
	
	// Others
	/**
	Perform animation for updating selected index
	
	:param: index new selected index
	*/
	fileprivate func updateSelectedIndex(_ index: Int) {
		var previousLabel: UILabel? = nil
		if previousSelectedIndex >= 0 {
			previousLabel = itemLabels[previousSelectedIndex]
		}
		let currentLabel = itemLabels[index]
		
		NSLayoutConstraint.deactivate([underScoreLeadingConstraint!, underScoreTrailingConstraint!])
		
		underScoreLeadingConstraint = NSLayoutConstraint(item: selectedUnderScoreView, attribute: .leading, relatedBy: .equal, toItem: currentLabel, attribute: .leading, multiplier: 1.0, constant: 0.0)
		underScoreTrailingConstraint = NSLayoutConstraint(item: selectedUnderScoreView, attribute: .trailing, relatedBy: .equal, toItem: currentLabel, attribute: .trailing, multiplier: 1.0, constant: 0.0)
		
		NSLayoutConstraint.activate([underScoreLeadingConstraint!, underScoreTrailingConstraint!])
		
		// If there's no selected index, means it's the first time selection, update width and centerX without animation
		if previousSelectedIndex == -1 {
			self.layoutIfNeeded()
		}
		
		underScoreHeightConstraint?.constant = underScoreHeight
		
		addFadeTransitionAnimationForLabel(previousLabel)
		addFadeTransitionAnimationForLabel(currentLabel)
		
		UIView.animate(withDuration: shouldBeAnimated ? animationDuration : 0.0, delay: 0.0, usingSpringWithDamping: 0.75, initialSpringVelocity: 0.0, options: .beginFromCurrentState, animations: { () -> Void in
			previousLabel?.textColor = self.titleUnSelectedColor ?? self.borderColor
			currentLabel.textColor = self.titleSelectedColor ?? self.tintColor
			
			self.layoutIfNeeded()
		}, completion: nil)
	}
}

extension SegmentedControl {
	@objc fileprivate func zh_selectedIndexChanged(_ sender: AnyObject) {
		if let segmentedControl = sender as? UISegmentedControl {
			updateSelectedIndex(segmentedControl.selectedSegmentIndex)
			previousSelectedIndex = segmentedControl.selectedSegmentIndex
		}
	}
}
