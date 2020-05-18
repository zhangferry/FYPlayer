//
//  VideoListTableViewCell.swift
//  FYPlayer
//
//  Created by 张飞 on 2020/3/8.
//  Copyright © 2020 zhangferry. All rights reserved.
//

import Foundation
import SnapKit
import Kingfisher

class VideoListTableViewCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        return label
    }()
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    private lazy var source: UILabel = {
        let label = UILabel()
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.selectionStyle = .none
        contentView.addSubview(titleLabel)
        contentView.addSubview(coverImageView)
        contentView.addSubview(source)
        
        titleLabel.snp.makeConstraints { (make) in
            make.leading.top.equalToSuperview().offset(Constraint.edge)
            make.centerX.equalToSuperview()
        }
        coverImageView.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleLabel.snp.bottom).offset(Constraint.edge)
            make.leading.equalToSuperview().offset(Constraint.edge)
            make.height.equalTo(self.coverImageView.snp.width).multipliedBy(0.7)
        }
        source.snp.makeConstraints { (make) in
            make.trailing.equalToSuperview().offset(-Constraint.edge)
            make.top.equalTo(self.coverImageView.snp.bottom).offset(20)
            make.bottom.equalToSuperview().offset(-20)
        }
    }
    
    func bindModel(_ video: VideoItem) {
        titleLabel.text = video.title
        coverImageView.kf.setImage(with: URL(string: video.imageUrl))
        source.text = video.source
    }
}
