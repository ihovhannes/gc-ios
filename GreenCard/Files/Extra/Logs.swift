//
// Created by Hovhannes Sukiasian on 10/11/2017.
// Copyright (c) 2017 Appril. All rights reserved.
//

import Foundation

public func log(_ message: Any = "", path: String = #file, lineNumber: Int = #line, function: String = #function) {
#if DEBUG
    let thread = Thread.current
    var threadName = "";
    if thread.isMainThread {
        threadName = "Main";
    } else if let name = thread.name, !name.isEmpty {
        threadName = name;
    } else {
        threadName = String(format: "%p", thread);
    }

    if let fileName = NSURL(fileURLWithPath: path).deletingPathExtension?.lastPathComponent {
        print("[\(threadName)] \(fileName).\(function):\(lineNumber) -- \(message)");
    } else {
        print("[\(threadName)] \(path).\(function):\(lineNumber) -- \(message)");
    }
#endif
}
