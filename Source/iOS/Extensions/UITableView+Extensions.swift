//
//  UITableView+Extensions.swift
//  Pods
//
//  Created by Honghao Zhang on 2015-12-16.
//
//

import UIKit

public extension UITableView {
	public func clearSelectedIndexPaths(animated animated: Bool) {
		guard let selectedIndexPaths = indexPathsForSelectedRows else {
			return
		}
		
		selectedIndexPaths.forEach { [unowned self] in
			self.deselectRowAtIndexPath($0, animated: animated)
		}
	}
	
	public func scrollsToTop(animated: Bool) {
		setContentOffset(CGPoint(x: 0.0, y: -contentInset.top), animated: animated)
	}
}
