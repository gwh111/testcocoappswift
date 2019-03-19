//
//  DataModel.swift
//  TableViewTest3
//
//  Created by Su Xiaozhou on 25/04/2017.
//  Copyright © 2017 Su Xiaozhou. All rights reserved.
//

import Cocoa

class DataModel: NSObject {
    let title: String
    let detail: String
    let imageName: String = "thumb"
    
    init(t: String, d: String) {
        title = t
        detail = d
    }
}
