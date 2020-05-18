//
//  ViewModelType.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/5/18.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation

protocol ViewModelType {
    associatedtype Input
    associatedtype Output
    
    func transform(input: Input) -> Output
}
