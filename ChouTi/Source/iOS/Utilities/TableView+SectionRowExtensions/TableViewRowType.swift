//
//  TableViewRowType.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-12-02.
//
//

import Foundation

public protocol TableViewRowType {
	var title: String? { get set }
	var subtitle: String? { get set }
    
    /// Initialize a cell
	var cellInitialization: ((IndexPath, UITableView) -> UITableViewCell)? { get set }
    /// Configure a cell after cell is initialized
	var cellConfiguration: ((IndexPath, UITableViewCell, UITableView) -> Void)? { get set }
    
    var willDisplayCell: ((IndexPath, UITableViewCell, UITableView) -> Void)? { get set }
    
	var cellSelectAction: ((IndexPath, UITableViewCell?, UITableView) -> Void)? { get set }
	var cellDeselectAction: ((IndexPath, UITableViewCell?, UITableView) -> Void)? { get set }
}
