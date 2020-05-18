//
//  VideoListViewModel.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/5/18.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class VideoListViewModel: ViewModelType {
    struct Input {
        let select: Driver<VideoItem>
    }
    
    struct Output {
        let currentList: Observable<[VideoItem]>
    }
    
    private let audioListRelay = BehaviorRelay<[VideoItem]>(value: [])
    private let currentAudio = PublishSubject<VideoItem>()
    private let disposeBag = DisposeBag()
    
    func transform(input: Input) -> Output {
        loadAudioList()
        input.select.drive(onNext: { (item) in
            self.select(video: item)
            }).disposed(by: disposeBag)
        
        return Output.init(currentList: audioListRelay.asObservable())
    }
}

extension VideoListViewModel {
    
    func loadAudioList() {
        guard let url = Bundle.main.url(forResource: "video_list", withExtension: "json") else {
            return
        }
        do {
            let data = try Data.init(contentsOf: url)
            let list = try JSONDecoder().decode([VideoItem].self, from: data)
            audioListRelay.accept(list)
            currentAudio.onNext(list[0])
        } catch let error {
            print(error.localizedDescription)
        }
    }
    func getAudioList() -> Observable<[VideoItem]> {
        return audioListRelay.asObservable()
    }
    
    func select(video: VideoItem) {
        /* logic code */
    }
}
