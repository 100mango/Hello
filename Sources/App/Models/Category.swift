//
//  Category.swift
//  HelloPackageDescription
//
//  Created by mangofang on 2017/10/30.
//

import Foundation
import FluentProvider

final class Category: Model {
    
    static let entity = "categories"
    
    let storage = Storage()
    
    let name: String
    
    init(name: String) {
        self.name = name
    }
    
    init(row: Row) throws {
        name = try row.get("name")
    }
    
    func makeRow() throws -> Row {
        var row = Row()
        try row.set("name", name)
        return row
    }
    
    static func addCategory(_ name: String, to reminder: Reminder) throws {
        var category: Category
        
        let foundCategory = try Category.makeQuery().filter("name", name).first()
        
        if let existingCategory = foundCategory {
            category = existingCategory
        } else {
            category = Category(name: name)
            try category.save()
        }
        
        try category.reminders.add(reminder)
    }
}

extension Category: Preparation {
    static func prepare(_ database: Database) throws {
        try database.create(self) { builder in
            builder.id()
            builder.string("name")
        }
    }
    
    static func revert(_ database: Database) throws {
        try database.delete(self)
    }
}

extension Category {
    var reminders: Siblings<Category, Reminder, Pivot<Category, Reminder>> {
        return siblings()
    }
}

extension Category: JSONConvertible {
    convenience init(json: JSON) throws {
        try self.init(name: json.get("name"))
    }
    
    func makeJSON() throws -> JSON {
        var json = JSON()
        try json.set("id", id)
        try json.set("name", name)
        return json
    }
}

extension Category: ResponseRepresentable {}
