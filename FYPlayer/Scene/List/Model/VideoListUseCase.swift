//
//  VideoListUseCase.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/3/8.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class VidoListUseCase {
    private let audioList = BehaviorRelay<[VideoItem]>(value: [])
    private let currentAudio = PublishSubject<VideoItem>()
    
    func loadAudioList() {
        guard let url = Bundle.main.url(forResource: "video_list", withExtension: "json") else {
            return
        }
        do {
            let data = try Data.init(contentsOf: url)
            let list = try JSONDecoder().decode([VideoItem].self, from: data)
            audioList.accept(list)
            currentAudio.onNext(list[0])
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func getAudioList() -> Observable<[VideoItem]> {
        return audioList.asObservable()
    }
    
    func select(video: VideoItem) {
        
    }
    
}
