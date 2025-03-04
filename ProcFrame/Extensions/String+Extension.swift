//
//  String+Extension.swift
//  ProcFrame
//
//  Created by yury antony on 04/03/25.
//

import Foundation

extension String {
    var deletingPathExtension: String {
        (self as NSString).deletingPathExtension
    }
}
