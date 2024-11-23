//
//  MemberViewModel.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import Foundation
import SQLite3


import Foundation

class MemberViewModel: ObservableObject {
    @Published var members: [Member] = []

    private let db = DatabaseHelper.shared

    func fetchMembers() {
        members.removeAll()
        let sql = "SELECT id, name FROM Members;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                members.append(Member(id: id, name: name))
            }
        }
        sqlite3_finalize(stmt)
    }

    func addMember(name: String) {
        guard !name.isEmpty else { return }
        let sql = "INSERT INTO Members (name) VALUES (?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        fetchMembers()
    }

    func updateMember(id: Int32, name: String) {
        guard !name.isEmpty else { return }
        let sql = "UPDATE Members SET name = ? WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (name as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 2, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        fetchMembers()
    }

    func deleteMember(id: Int32) {
        let sql = "DELETE FROM Members WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        fetchMembers()
    }
}
