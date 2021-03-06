//
//  UIImage+ExtensionsDemo.swift
//  ChouTi iOS Example
//
//  Created by Honghao Zhang on 2016-08-07.
//  Copyright © 2016 Honghaoz. All rights reserved.
//

import UIKit
import ChouTi

class UIImageExtensionsDemoViewController: UIViewController {
    let tableView = UITableView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "UIImage+Extensions Demo"
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(tableView)
        tableView.constrainToFullSizeInSuperview()
        
        tableView.sections = [
            TableViewSection(rows: [
                TableViewRow(title: "UIImage+CroppedImage",
                    cellSelectAction: { [weak self] indexPath, cell, tableView in
                        self?.tableView.deselectRow(at: indexPath, animated: true)
                        let demoViewController = UIImage_CroppedImageDemoViewController()
                        self?.show(demoViewController, sender: nil)
                    }),
                TableViewRow(title: "UIImage+AnimatingImages", subtitle: "Sprite in UIKit",
                    cellSelectAction: { [weak self] indexPath, cell, tableView in
                        self?.tableView.deselectRow(at: indexPath, animated: true)
                        let demoViewController = UIImage_AnimatingImagesDemoViewController()
                        self?.show(demoViewController, sender: nil)
                    })
            ])
        ]
    }
}
