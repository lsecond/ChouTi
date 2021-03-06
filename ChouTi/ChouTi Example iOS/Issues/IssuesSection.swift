//
//  IssuesSection.swift
//  ChouTi iOS Example
//
//  Created by Honghao Zhang on 2016-07-05.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import Foundation
import ChouTi

struct IssuesSection: TableViewSectionType {
    var headerTitle: String? = "Issues"
    var rows: [TableViewRowType] = {
        return [
            TableViewRow(title: "Issue: `layoutMarginsGuide`",
                subtitle: "layoutMarginsGuide.topAnchor is not same as .TopMargin",
                cellSelectAction: { (indexPath, cell, tableView) -> Void in
                    cell?.tableView?.deselectRow(at: indexPath, animated: true)
                    cell?.tableView?.presentingViewController?.show(Issue_LayoutMarginsGuideViewController(), sender: nil)
                }
            ),
            TableViewRow(title: "Issue: `preservesSuperviewLayoutMargins`",
                subtitle: "Demo for `preservesSuperviewLayoutMargins`",
                cellSelectAction: { (indexPath, cell, tableView) -> Void in
                    cell?.tableView?.deselectRow(at: indexPath, animated: true)
                    cell?.tableView?.presentingViewController?.show(Issue_PreservesSuperviewLayoutMargins(), sender: nil)
                }
            ),
			TableViewRow(title: "Issue: TableViewCell contentView 0 width.",
                cellSelectAction: { (indexPath, cell, tableView) -> Void in
					cell?.tableView?.deselectRow(at: indexPath, animated: true)
					cell?.tableView?.presentingViewController?.show(Issue_IncorrectTableViewCellContentViewWidth(), sender: nil)
				}
			)
        ]
    }()
}
