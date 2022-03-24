//
//  LoadingTableFooter.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 13.01.2018.
//  Copyright © 2018 Appril. All rights reserved.
//

import UIKit
import Lottie
import Look
import SnapKit

class LoadingTableFooter: UIView {

    fileprivate(set) var spinner = LOTAnimationView(name: "loading_indicator")
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(spinner)
        
        spinner.snp.makeConstraints { maker in
            maker.width.equalTo(100)
            maker.height.equalTo(100 * 0.75)
            maker.center.equalToSuperview()
        }
        
        look.apply(Style.loaderStyle)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

fileprivate extension Style {
    static var loaderStyle: Change<LoadingTableFooter> {
        return { (view: LoadingTableFooter) -> Void in
            view.backgroundColor = Palette.Common.transparentBackground.color
            view.spinner.loopAnimation = true
        }
    }
}
