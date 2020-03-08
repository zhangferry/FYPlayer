//
//  Configs.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/2/12.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation
import UIKit

struct Configs {
    
}

struct Constraint {
    static let screenHeight = UIScreen.main.bounds.height
    static let screenWidth = UIScreen.main.bounds.width
    
    static var safeAreaInsets: UIEdgeInsets {
        guard #available(iOS 11.0, *), let keyWindow = UIApplication.shared.keyWindow else {
            return UIEdgeInsets.init(top: self.statusBarHeight, left: 0, bottom: 0, right: 0)
        }
        //in ios 11, there is just a status bar (iPhone 6,7,...). It will return 0 for the top inset height, may be a system bug
        var edgeInsets = keyWindow.safeAreaInsets
        if !UIApplication.shared.isStatusBarHidden, edgeInsets.top == 0 {
            edgeInsets.top = self.statusBarHeight
        }
        return edgeInsets
    }
    
    static var isIphoneX: Bool {
        //return UIApplication.shared.statusBarFrame.size.height == 44
        return self.homeIndicatorHeight == 34 || self.homeIndicatorHeight == 21
    }
    
    static var homeIndicatorHeight: CGFloat {
        return self.safeAreaInsets.bottom
    }
    
    /** height of statusbar, 20:44 */
    static var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height
    }
}
