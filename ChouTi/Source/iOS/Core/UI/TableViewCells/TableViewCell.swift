//
//  TableViewCell.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2015-11-19.
//  Copyright © 2015 Honghao Zhang. All rights reserved.
//

import UIKit

open class TableViewCell: UITableViewCell {
	
	/// Cell height, this is the constant for height constraint (250 priority).
	//	Discussion: You can fully specify cell's height to ignore cell height (Use constraints with priorty greater than 250)
	open var cellHeight: CGFloat = 44.0 {
		didSet {
			_heightConstraint?.constant = cellHeight
		}
	}
	
	fileprivate var _heightConstraint: NSLayoutConstraint?
	
	open var selectedAccessoryView: UIView?
	open var selectedAccessoryType: UITableViewCellAccessoryType = .none
	
	public override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
		super.init(style: style, reuseIdentifier: reuseIdentifier)
		commonInit()
	}
	
	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}
	
	open func commonInit() {
		_heightConstraint = NSLayoutConstraint(item: contentView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 0.0, constant: cellHeight)
		_heightConstraint?.priority = 250
		_heightConstraint?.isActive = true
	}
	
	open override func setSelected(_ selected: Bool, animated: Bool) {
		super.setSelected(selected, animated: animated)
		
		if selectedAccessoryType != .none {
			accessoryType = selected ? selectedAccessoryType : .none
		}
		
		if selectedAccessoryView != nil {
			accessoryView = selected ? selectedAccessoryView : nil
		}
	}
}
