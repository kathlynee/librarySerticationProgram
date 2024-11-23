//
//  CategoryViewModel.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import Foundation
import SQLite3

class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []

    private let db = DatabaseHelper.shared

    func fetchCategories() {
        categories.removeAll()
        let sql = "SELECT id, name FROM Categories;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                categories.append(Category(id: id, name: name))
            }
        }
        sqlite3_finalize(stmt)
    }

    func addCategory(name: String) {
        guard !name.isEmpty else { return }
        let sql = "INSERT INTO Categories (name) VALUES (?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        fetchCategories()
    }

    func updateCategory(id: Int32, name: String) {
        guard !name.isEmpty else { return }
        let sql = "UPDATE Categories SET name = ? WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        fetchCategories()
    }

    func deleteCategory(id: Int32) {
        let sql = "DELETE FROM Categories WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        fetchCategories()
    }
}
