//
//  VideoListItem.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/3/8.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation

struct VideoItem: Codable {
    let title: String
    let videoUrl: String
    let imageUrl: String
    let summary: String
    let source: String
    let date: String
    
    enum CodingKeys: String, CodingKey {
        case title
        case videoUrl = "video_url"
        case imageUrl = "image_url"
        case summary
        case source
        case date
    }
}
