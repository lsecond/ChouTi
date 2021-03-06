//
//  TableView+Sections.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-12-02.
//
//

import UIKit

public extension UITableView {
	fileprivate struct zhSectionsKey {
		static var Key = "zhSectionsKey"
	}
	
	// https://wezzard.com/2015/10/09/associated-object-and-swift-struct/
	public var sections: [TableViewSectionType]? {
		get {
			let object = objc_getAssociatedObject(self, &zhSectionsKey.Key)
			return StructWrapper<[TableViewSectionType]>.structFromObject(object)
		}
		
		set {
			let object = StructWrapper<[TableViewSectionType]>.objectFromStruct(newValue)
			if object == nil {
				tearUp()
			} else {
				setup()
			}
			objc_setAssociatedObject(self, &zhSectionsKey.Key, object, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		}
	}
	
	fileprivate func setup() {
		if dataSource == nil {
			dataSource = self
        } else if dataSource !== self {
            NSLog("Warning: tableView.dataSource is not nil, setting sections won't have effects. TableView: \(self)")
        }
		
		if delegate == nil {
			delegate = self
        } else if delegate !== self {
            NSLog("Warning: tableView.delegate is not nil, setting sections won't have effects. TableView: \(self)")
        }
        
        self.rowHeight = UITableViewAutomaticDimension
        
		TableViewCell.registerInTableView(self)
		TableViewCellValue1.registerInTableView(self)
		TableViewCellValue2.registerInTableView(self)
		TableViewCellSubtitle.registerInTableView(self)
	}
	
	fileprivate func tearUp() {
		dataSource = nil
		delegate = nil
		
		TableViewCell.unregisterInTableView(self)
		TableViewCellValue1.unregisterInTableView(self)
		TableViewCellValue2.unregisterInTableView(self)
		TableViewCellSubtitle.unregisterInTableView(self)
	}
}



// MARK: - TableView DataSource Methods
extension UITableView : UITableViewDataSource {
    // Row
	public func numberOfSections(in tableView: UITableView) -> Int {
		return sections?.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sectionForIndex(section)?.rows.count ?? 0
	}
	
	public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let row = rowForIndexPath(indexPath) else {
			print("Error: row not found")
			return UITableViewCell()
		}
		
		var cell: UITableViewCell! = nil
		
		if let cellInitialization = row.cellInitialization {
			cell = cellInitialization(indexPath, tableView)
		} else {
            cell = tableView.dequeueReusableCell(withClass: TableViewCellSubtitle.self)
		}
		
		tableView.tableView(tableView, cellConfigurationForCell: cell, atIndexPath: indexPath)
		
		return cell
	}
	
	fileprivate func tableView(_ tableView: UITableView, cellConfigurationForCell cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        rowForIndexPath(indexPath)?.cellConfiguration?(indexPath, cell, tableView)
	}
	
    // Section Index
	public func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		guard let sections = sections else {
			print("Warning: no sections in \(self)")
			return nil
		}
		
		// If there's no one section wants show index, return nil
		if sections.filter({ $0.shouldShowIndex }).count == 0 {
			return nil
		}
		
		return sections.map { $0.shouldShowIndex ? ($0.headerTitle ?? "") : "" }
	}
	
	// Header
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionForIndex(section)?.headerTitle
    }
	
	// Footer
    public func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return sectionForIndex(section)?.footerTitle
    }
}


// MARK: - TableView Delegate Methods
extension UITableView : UITableViewDelegate {
    // Row
	public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
	}
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
	
	public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		rowForIndexPath(indexPath)?.cellSelectAction?(indexPath, tableView.cellForRow(at: indexPath), tableView)
	}
	
	public func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		rowForIndexPath(indexPath)?.cellDeselectAction?(indexPath, tableView.cellForRow(at: indexPath), tableView)
	}
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        rowForIndexPath(indexPath)?.willDisplayCell?(indexPath, cell, tableView)
    }
    
    // Header
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionForIndex(section)?.headerHeight?(section, tableView) ?? UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return sectionForIndex(section)?.headerView?(section, tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        sectionForIndex(section)?.headerWillDisplay?(section, view, tableView)
    }
    
    // Footer
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sectionForIndex(section)?.footerHeight?(section, tableView) ?? UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return sectionForIndex(section)?.footerView?(section, tableView)
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        sectionForIndex(section)?.footerWillDisplay?(section, view, tableView)
    }
}

public extension UITableView {
	public func sectionForIndex(_ index: Int) -> TableViewSectionType? {
		guard let sections = sections else {
			print("Warning: no sections in \(self)")
			return nil
		}
		
		if index < sections.count {
			let section = sections[index]
			return section
		} else {
			print("Warning: seciton index out of range")
			return nil
		}
	}
	
	public func rowForIndexPath(_ indexPath: IndexPath) -> TableViewRowType? {
		guard let sections = sections else {
			print("Warning: no sections in \(self)")
			return nil
		}
		
		guard indexPath.section < sections.count else {
			print("Warning: seciton index out of range")
			return nil
		}
		
		let section = sections[indexPath.section]
		guard indexPath.row < section.rows.count else {
			print("Warning: row index out of range")
			return nil
		}
		
		return section.rows[indexPath.row]
	}
}
