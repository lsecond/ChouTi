//
//  DropDownMenuPickerViewController.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-12-09.
//
//

import UIKit

class DropDownMenuPickerViewController : UIViewController {
	
	/// Table view for options
	let tableView = UITableView()
	
	/// The drop down menu using this picker view controller
	weak var dropDownMenu: DropDownMenu?
	
	var statusBarStyle: UIStatusBarStyle = .default
	
	/// Sliding up/down animation duration. By default is 0.5s
	var animationDuration: TimeInterval = 0.5
	
	/// Option cell height. By default is 44.0
	var optionCellHeight: CGFloat = 44.0 {
		didSet {
            // 0.5 is for separator line
            tableViewHeightConstraint?.constant = ceil((optionCellHeight + 0.5) * CGFloat(numberOfOptions))
		}
	}
	
	fileprivate var _optionTextColor: UIColor?
	/// Menu options text color
	var optionTextColor: UIColor? {
		get {
			return _optionTextColor ?? UIColor.black
		}
		
		set {
			_optionTextColor = newValue
		}
	}
	
	fileprivate var _optionTextFont: UIFont?
	/// Menu options text font
	var optionTextFont: UIFont? {
		get {
			return _optionTextFont ?? dropDownMenu?.textLabel.font
		}
		set {
			_optionTextFont = newValue
		}
	}
	
	fileprivate var _optionTextAlignment: NSTextAlignment?
	/// Menu options text alignment
	var optionTextAlignment: NSTextAlignment {
		get {
			return _optionTextAlignment ?? dropDownMenu?.textLabel.textAlignment ?? .left
		}
		set {
			_optionTextAlignment = newValue
		}
	}
	
	fileprivate var _optionCellBackgroundColor: UIColor?
	/// Menu options cell background color
	var optionCellBackgroundColor: UIColor? {
		get {
			return _optionCellBackgroundColor ?? UIColor.white
		}
		set {
			_optionCellBackgroundColor = newValue
			tableView.backgroundColor = _optionCellBackgroundColor
		}
	}
	
	fileprivate var _optionSeparatorColor: UIColor? {
		didSet {
			tableView.separatorColor = _optionSeparatorColor
		}
	}
	/// Color for separator between options
	var optionSeparatorColor: UIColor? {
		get {
			return _optionSeparatorColor ?? UIColor(white: 0.75, alpha: 1.0)
		}
		set {
			_optionSeparatorColor = newValue
		}
	}
	
    /// an offset cover view, which covers the gap between the menu and the first option cell
    fileprivate let topOffsetView = UIView()
    
    fileprivate(set) var isExpanded: Bool = false {
        didSet {
            dropDownMenu?.expanded = isExpanded
        }
    }
    
	fileprivate var isAnimating: Bool = false
	fileprivate var didAppear: Bool = false

	fileprivate var tableViewHeightConstraint: NSLayoutConstraint!
	fileprivate var expandedConstraints = [NSLayoutConstraint]()
	fileprivate var collapsedConstraints = [NSLayoutConstraint]()
	
	fileprivate var numberOfOptions: Int {
		return tableView(tableView, numberOfRowsInSection: 0)
	}
	
	override var preferredStatusBarStyle: UIStatusBarStyle {
		return statusBarStyle
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if let dropDownMenu = dropDownMenu {
			optionCellHeight = dropDownMenu.height
		}
		
		setupViews()
		setupConstraints()
	}

	fileprivate func setupViews() {
		view.clipsToBounds = true
		
		tableView.translatesAutoresizingMaskIntoConstraints = false
		view.addSubview(tableView)
		
		tableView.backgroundColor = UIColor.clear
		
		tableView.separatorStyle = .singleLine
		tableView.separatorInset = UIEdgeInsets.zero
		
		tableView.dataSource = self
		tableView.delegate = self
		tableView.rowHeight = UITableViewAutomaticDimension
		
		tableView.canCancelContentTouches = true
		tableView.delaysContentTouches = true
		
		tableView.showsVerticalScrollIndicator = false
		tableView.showsHorizontalScrollIndicator = false
		
        // Only scroll when options are not fitting in tableView
        tableView.alwaysBounceVertical = false
        
		TableViewCell.registerInTableView(tableView)
        
        topOffsetView.backgroundColor = optionCellBackgroundColor
        topOffsetView.frame = CGRect.zero
        view.insertSubview(topOffsetView, belowSubview: tableView)
	}

	fileprivate func setupConstraints() {
		let views = [
			"tableView" : tableView
		]

		let metrics: [String : CGFloat] = [:]

		var constraints = [NSLayoutConstraint]()

		tableViewHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: ceil((optionCellHeight + 0.5) * CGFloat(numberOfOptions)))
		tableViewHeightConstraint.priority = 750
		constraints += [tableViewHeightConstraint]
		
		let maxHeightConstraint = NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .lessThanOrEqual, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0.0)
		constraints += [maxHeightConstraint]
		
		collapsedConstraints += [
			NSLayoutConstraint(item: tableView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
		]
		constraints += collapsedConstraints
		
		expandedConstraints += [
			NSLayoutConstraint(item: tableView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
		]
		
		constraints += NSLayoutConstraint.constraints(withVisualFormat: "H:|[tableView]|", options: [], metrics: metrics, views: views)
		
		NSLayoutConstraint.activate(constraints)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		if let dropDownMenu = dropDownMenu {
			optionCellHeight = dropDownMenu.height
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		
		didAppear = true
	}
	
	override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		
		// Expand options should be called when picker view is about to appear
		if didAppear == true {
			return
		}

		// Expand options table view here because picker view is about to appear
		expandOptions()
        
        // Update view size to have same size as tableview
        let numberOfOptions = tableView(tableView, numberOfRowsInSection: 0)
        view.frame.size.height = min(ceil((optionCellHeight + 0.5) * CGFloat(numberOfOptions)), screenSize.height - view.top)
	}
	
	override func viewDidDisappear(_ animated: Bool) {
		super.viewDidDisappear(animated)
		
		didAppear = false
	}

	override func dismiss(animated flag: Bool, completion: (() -> Void)?) {
		// Collapse options first then dismiss
		collapseOptions({ _ in
			super.dismiss(animated: flag, completion: completion)
		})
	}
}



// MARK: - Animations
extension DropDownMenuPickerViewController {
	
	/**
	Expand options list
	
	- parameter completion: optional completion block
	*/
	func expandOptions(_ completion: ((Bool) -> Void)? = nil) {
		if isExpanded || isAnimating {
			completion?(false)
			return
		}
		
		NSLayoutConstraint.deactivate(collapsedConstraints)
		NSLayoutConstraint.activate(expandedConstraints)
		
		isAnimating = true
		tableView.reloadData()
		UIView.animate(withDuration: animationDuration, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
			self.view.layoutIfNeeded()
		}, completion: { finished in
			self.isExpanded = true
			self.isAnimating = false
			
			if let dropDownMenu = self.dropDownMenu {
				dropDownMenu.didExpand()
			} else {
				print("Warning: drop down menu in picker view controller is nil")
			}
			
			completion?(finished)
		})
	}
	
	/**
	Collapse options list
	
	- parameter completion: optional completion block
	*/
	func collapseOptions(_ completion: ((Bool) -> Void)? = nil) {
		if isExpanded == false || isAnimating {
			completion?(false)
			return
		}
		
		NSLayoutConstraint.deactivate(expandedConstraints)
		NSLayoutConstraint.activate(collapsedConstraints)
		
		if let dropDownMenu = dropDownMenu {
			dropDownMenu.willCollapse()
		} else {
			print("Warning: drop down menu in picker view controller is nil")
		}
		
		isAnimating = true
		
		// Since the dim background dim out animation is executed after collapsing, to speed up the whole animation, here used 2 / 3 of duration
		UIView.animate(withDuration: animationDuration * 2 / 3, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.5, options: [.curveEaseInOut, .beginFromCurrentState], animations: {
			self.view.layoutIfNeeded()
		}, completion: { [unowned self] finished in
			self.isExpanded = false
			self.isAnimating = false
			
			if let dropDownMenu = self.dropDownMenu {
                dropDownMenu.didCollapse()
			} else {
				print("Warning: drop down menu in picker view controller is nil")
			}
			
			completion?(finished)
		})
	}
}



// MARK: - UITableViewDataSource
extension DropDownMenuPickerViewController : UITableViewDataSource {
	func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		guard let dropDownMenu = dropDownMenu else {
			assertionFailure("Error: dropDownMenu is nil")
			return 0
		}
		
		guard let menuDataSource = dropDownMenu.dataSource else {
			assertionFailure("Error: dataSource for DropDownMenu is nil")
			return 0
		}
		
		return menuDataSource.numberOfOptionsInDropDownMenu(dropDownMenu)
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier()) as! TableViewCell
		
		guard let dropDownMenu = dropDownMenu else {
			assertionFailure("Error: dropDownMenu is nil")
			return cell
		}
		
		cell.textLabel?.text = dropDownMenu.dataSource.dropDownMenu(dropDownMenu, optionTitleForIndex: indexPath.row)
		
		cell.cellHeight = optionCellHeight
		cell.textLabel?.textColor = optionTextColor
		cell.textLabel?.font = optionTextFont
		cell.textLabel?.textAlignment = optionTextAlignment
		cell.backgroundColor = optionCellBackgroundColor
        cell.selectionStyle = .none
		
		// Full width separator
		cell.enableFullWidthSeparator()
		
		return cell
	}
}



// MARK: - UITableViewDelegate
extension DropDownMenuPickerViewController : UITableViewDelegate {
	// MARK: - Rows
	func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return TableViewCell.estimatedHeight()
	}

	// MARK: - Selections
	func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
		guard let dropDownMenu = dropDownMenu else {
			assertionFailure("Error: dropDownMenu is nil")
			return indexPath
		}
		
		dropDownMenu.delegate?.dropDownMenu?(dropDownMenu, willSelectIndex: indexPath.row)
		return indexPath
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let dropDownMenu = dropDownMenu else {
			assertionFailure("Error: dropDownMenu is nil")
			return
		}
        
        dropDownMenu.set(toExpand: false, animated: true)
        dropDownMenu.selectedIndex = indexPath.row
		dropDownMenu.delegate?.dropDownMenu?(dropDownMenu, didSelectIndex: indexPath.row)
	}
}



// MARK: - UIScrollViewDelegate
extension DropDownMenuPickerViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // If scrolls to top, add an offset cover view, which covers the gap between the menu and the first option cell
        if scrollView.contentOffset.y <= 0 {
            topOffsetView.frame = CGRect(x: 0, y: 0, width: tableView.width, height: -scrollView.contentOffset.y)
        } else {
            topOffsetView.frame = CGRect.zero
        }
    }
}
