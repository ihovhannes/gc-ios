//
// Created by Hovhannes Sukiasian on 11/01/2018.
// Copyright (c) 2018 Appril. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa

class RxKeyboard {

    static func keyboardHeight() -> Observable<(height: CGFloat, animDuration: TimeInterval)> {
        return Observable
                .from([
                    NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillChangeFrame)
                            .map { notification -> (height: CGFloat, animDuration: TimeInterval) in
                                let height =
                                        (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue.height ?? 0
                                var duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
                                duration = duration > 0 ? duration : 0.4
                                return (height: height, animDuration: duration)
                            },
                    NotificationCenter.default.rx.notification(NSNotification.Name.UIKeyboardWillHide)
                            .map { notification -> (height: CGFloat, animDuration: TimeInterval) in
                                var duration = (notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
                                duration = duration > 0 ? duration : 0.4
                                return (height: CGFloat(0), animDuration: duration)
                            }
                ])
                .merge()
    }


}
