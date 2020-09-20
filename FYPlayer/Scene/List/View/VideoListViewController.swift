//
//  VideoListViewController.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/2/1.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class VideoListViewController: UIViewController {

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(VideoListTableViewCell.self, forCellReuseIdentifier: VideoListTableViewCell.reuseId)
        return tableView
    }()
    private let viewModel: VideoListViewModel
    private let disposeBag = DisposeBag()
    
    init(viewModel: VideoListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindModel()
    }
    
    private func setupUI() {
        self.navigationItem.title = "Videos"
        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    private func bindModel() {
        let selectDriver = tableView.rx.modelSelected(VideoItem.self)
        let input = VideoListViewModel.Input.init(select: selectDriver.asDriver())
        let output = viewModel.transform(input: input)
        
        output.currentList.bind(to: tableView.rx.items) { (tableview, index, element) in
            guard let cell = tableview.dequeueReusableCell(withIdentifier: VideoListTableViewCell.reuseId) as? VideoListTableViewCell else {
                return UITableViewCell()
            }
            cell.bindModel(element)
            return cell
        }.disposed(by: disposeBag)
    }

}
