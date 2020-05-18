//
//  TableViewCell+Ext.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/5/18.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation

extension UITableViewCell {
    static var reuseId: String {
        return String(describing: self)
    }
}
