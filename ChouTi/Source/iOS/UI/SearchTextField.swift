//
//  SearchTextField.swift
//  ChouTi
//
//  Created by Honghao Zhang on 2016-02-14.
//  Copyright © 2016 Honghao Zhang. All rights reserved.
//

import UIKit

public protocol SearchTextFieldDelegate: class {
    func searchTextFieldDidEdit(_ searchTextField: SearchTextField)
    func searchTextField(_ searchTextField: SearchTextField, willSelectIndex index: Int)
    func searchTextField(_ searchTextField: SearchTextField, didSelectIndex index: Int)
}

public protocol SearchTextFieldDataSource: class {
    func numberOfResults(forQueryString queryString: String?, inSearchTextField searchTextField: SearchTextField) -> Int
    func resultString(forIndex index: Int, inSearchTextField searchTextField: SearchTextField) -> String
    func resultAttributedString(forIndex index: Int, inSearchTextField searchTextField: SearchTextField) -> NSAttributedString?
    
    func configure(forResultCell resultCell: UITableViewCell, forIndex index: Int, inSearchTextField searchTextField: SearchTextField)
}

open class SearchTextField: TextField {
	open var maxNumberOfResults: Int = 3
    
	open weak var searchTextFieldDelegate: SearchTextFieldDelegate?
	open weak var searchTextFieldDataSource: SearchTextFieldDataSource?
    
    fileprivate var originalDelegate: UITextFieldDelegate?
    open override weak var delegate: UITextFieldDelegate? {
        didSet {
            originalDelegate = delegate
            super.delegate = self
        }
    }
    
	fileprivate var _resultTextColor: UIColor?
	/// Result text color
	open var resultTextColor: UIColor? {
		get {
			return _resultTextColor ?? UIColor.black
		}
		
		set {
			_resultTextColor = newValue
		}
	}
	
	fileprivate var _resultTextFont: UIFont?
	/// Menu results text font
	open var resultTextFont: UIFont? {
		get {
			return _resultTextFont ?? font
		}
		set {
			_resultTextFont = newValue
		}
	}
	
	fileprivate var _resultTextAlignment: NSTextAlignment?
	/// Menu results text alignment
	open var resultTextAlignment: NSTextAlignment {
		get {
			return _resultTextAlignment ?? textAlignment
		}
		set {
			_resultTextAlignment = newValue
		}
	}
	
	fileprivate var _resultCellBackgroundColor: UIColor?
	/// Menu results cell background color
	open var resultCellBackgroundColor: UIColor? {
		get {
			return _resultCellBackgroundColor ?? UIColor.white
		}
		set {
			_resultCellBackgroundColor = newValue
		}
	}
    
    fileprivate var _resultCellHeight: CGFloat?
    open var resultCellHeight: CGFloat {
        get {
            return _resultCellHeight ?? height
        }
        
        set {
            _resultCellHeight = newValue
        }
    }
	
	fileprivate var _resultSeparatorColor: UIColor? {
		didSet {
			resultTableView.separatorColor = _resultSeparatorColor
		}
	}
	/// Color for separator between results
	open var resultSeparatorColor: UIColor? {
		get {
			return _resultSeparatorColor ?? UIColor(white: 0.75, alpha: 1.0)
		}
		set {
			_resultSeparatorColor = newValue
		}
	}
	
	fileprivate let resultTableView = UITableView()
	
    fileprivate let searchTextFieldDidEdit = #selector(SearchTextField.zhh_searchTextFieldDidEdit(_:))
	
    fileprivate var overlayView: UIView?
	
	fileprivate var _heightConstraint: NSLayoutConstraint!
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		commonInit()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		commonInit()
	}

	fileprivate func commonInit() {
        autocorrectionType = .no
        
		resultTableView.translatesAutoresizingMaskIntoConstraints = false
		resultTableView.backgroundColor = UIColor.clear
		
		resultTableView.separatorStyle = .singleLine
		resultTableView.separatorInset = UIEdgeInsets.zero
		
		resultTableView.dataSource = self
		resultTableView.delegate = self
		resultTableView.rowHeight = UITableViewAutomaticDimension
		resultTableView.tableFooterView = UIView()
        
		resultTableView.canCancelContentTouches = true
		resultTableView.delaysContentTouches = true
		
		resultTableView.showsVerticalScrollIndicator = false
		resultTableView.showsHorizontalScrollIndicator = false
        resultTableView.isScrollEnabled = false
		
		TableViewCell.registerInTableView(resultTableView)
        
		addTarget(self, action: searchTextFieldDidEdit, for: .editingChanged)
        super.delegate = self
	}
	
	deinit {
		removeTarget(self, action: searchTextFieldDidEdit, for: .editingChanged)
	}
    
    open func reloadResults() {
        resultTableView.reloadSections(IndexSet(integer: 0), with: .automatic)
    }
}



// MARK: - UITextFieldDelegate
extension SearchTextField : UITextFieldDelegate {
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return originalDelegate?.textFieldShouldBeginEditing?(textField) ?? true
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        originalDelegate?.textFieldDidBeginEditing?(textField)
        zhh_searchTextFieldDidEdit(textField)
    }
    
    public func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        return originalDelegate?.textFieldShouldEndEditing?(textField) ?? true
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        originalDelegate?.textFieldDidEndEditing?(textField)
        tearDownOverlayView()
        tearDownResultTableView()
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return originalDelegate?.textField?(textField, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }
    
    public func textFieldShouldClear(_ textField: UITextField) -> Bool {
        return originalDelegate?.textFieldShouldClear?(textField) ?? true
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        return originalDelegate?.textFieldShouldReturn?(textField) ?? true
    }
    
	func zhh_searchTextFieldDidEdit(_ textField: UITextField) {
        searchTextFieldDelegate?.searchTextFieldDidEdit(self)
		if textField.text == nil || textField.text?.isEmpty == true {
            tearDownOverlayView()
			tearDownResultTableView()
		} else {
			setupOverlayView()
			setupResultTableView()
		}
	}
}



// MARK: - Helper
extension SearchTextField {
	fileprivate func setupOverlayView() {
        if overlayView != nil {
            return
        }
        
		guard let window = window else {
			NSLog("\(self).window is nil")
			return
		}
				
		overlayView = window.insertOverlayViewBelowSubview(self, animated: false, overlayViewBackgroundColor: UIColor.clear)
		overlayView?.isUserInteractionEnabled = false
		
		let tap = UITapGestureRecognizer(target: self, action: #selector(SearchTextField.overlayViewTapped(_:)))
        overlayView?.addGestureRecognizer(tap)
	}
    
    fileprivate func tearDownOverlayView() {
        if overlayView == nil {
            return
        }
        
        guard let window = window else {
            NSLog("\(self).window is nil")
            return
        }
        
        window.removeOverlayView()
        overlayView = nil
    }
	
	fileprivate func setupResultTableView() {
		if resultTableView.superview != nil {
			return
		}
		
		guard let window = window else {
			NSLog("\(self).window is nil")
			return
		}
		
		window.insertSubview(resultTableView, aboveSubview: self)

		var constraints = [NSLayoutConstraint]()
		
        constraints += [NSLayoutConstraint(item: resultTableView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1.0, constant: 0.0)]
        constraints += [NSLayoutConstraint(item: resultTableView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1.0, constant: 0.0)]
		constraints += [NSLayoutConstraint(item: resultTableView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1.0, constant: 0.0)]
		_heightConstraint = NSLayoutConstraint(item: resultTableView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: CGFloat(maxNumberOfResults) * (0.5 + resultCellHeight))
		constraints += [_heightConstraint]
        
		NSLayoutConstraint.activate(constraints)
	}
    
    fileprivate func tearDownResultTableView() {
        resultTableView.removeFromSuperview()
    }
    
    func overlayViewTapped(_ tapGesture: UITapGestureRecognizer) {
        self.resignFirstResponder()
    }
}



// MARK: - UITableViewDataSource
extension SearchTextField : UITableViewDataSource {
	public func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return searchTextFieldDataSource?.numberOfResults(forQueryString: text, inSearchTextField: self) ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCell.identifier()) as! TableViewCell
		
        if let attributedText = searchTextFieldDataSource?.resultAttributedString(forIndex: indexPath.row, inSearchTextField: self) {
            cell.textLabel?.attributedText = attributedText
        } else {
            cell.textLabel?.text = searchTextFieldDataSource?.resultString(forIndex: indexPath.row, inSearchTextField: self)
        }
		
		cell.cellHeight = resultCellHeight
		cell.textLabel?.textColor = resultTextColor
		cell.textLabel?.font = resultTextFont
		cell.textLabel?.textAlignment = resultTextAlignment
		cell.backgroundColor = resultCellBackgroundColor
		
		// Full width separator
		cell.enableFullWidthSeparator()
        
        searchTextFieldDataSource?.configure(forResultCell: cell, forIndex: indexPath.row, inSearchTextField: self)
		
		return cell
	}
}



// MARK: - UITableViewDelegate
extension SearchTextField : UITableViewDelegate {
	// MARK: - Rows
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
		return resultCellHeight
	}
	
	// MARK: - Selections
	public func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        searchTextFieldDelegate?.searchTextField(self, willSelectIndex: indexPath.row)
        
        text = tableView.cellForRow(at: indexPath)?.textLabel?.text
        
		return indexPath
	}

	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
        searchTextFieldDelegate?.searchTextField(self, didSelectIndex: indexPath.row)
        
        tearDownOverlayView()
        tearDownResultTableView()
	}
}
