//
//  UITableView.swift
//  GreenCard
//
//  Created by Hovhannes Sukiasian on 01.11.2017.
//  Copyright © 2017 Appril. All rights reserved.
//

import RxCocoa
import RxSwift
import UIKit

extension UITableView: Updateable {
    
    func update(object: UpdateableObject, completion: ((Bool) -> Void)?) {
        DispatchQueue.main.async { [weak self] in
            switch object.animated {
            case true:
                self?.beginUpdates()
                self?.deleteRows(at: object.updates.row.delete, with: .automatic)
                self?.insertRows(at: object.updates.row.insert, with: .automatic)
                self?.reloadRows(at: object.updates.row.reload, with: .automatic)
                self?.deleteSections(object.updates.section.delete, with: .automatic)
                self?.insertSections(object.updates.section.insert, with: .automatic)
                self?.endUpdates()
            case false:
                self?.reloadData()
                completion?(true)
            }
        }
    }
}

extension Reactive where Base: UITableView {
    
    var observerUpdates: AnyObserver<UpdateableObject> {
        return Binder.init(base, binding: { (view: UITableView, object: UpdateableObject) in
            view.update(object: object, completion: nil)
        }).asObserver()
    }
}

