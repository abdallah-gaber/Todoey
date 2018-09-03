//
//  Category.swift
//  Todoey
//
//  Created by Teqnia-Tech on 9/2/18.
//  Copyright © 2018 Teqnia-Tech. All rights reserved.
//

import Foundation
import RealmSwift

class Category: Object {
    @objc dynamic var name: String = ""
    let items = List<Item>()
}
