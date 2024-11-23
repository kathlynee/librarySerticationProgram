//
//  DatabaseHelper.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SQLite3
import Foundation

class DatabaseHelper {
    static let shared = DatabaseHelper()
    var db: OpaquePointer? // Membuat db public agar dapat diakses

    init() {
        openDatabase()
        createTables()
    }

    private func openDatabase() {
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("LibraryManagement.sqlite")
        
        print(fileURL.path)

        if sqlite3_open(fileURL.path, &db) != SQLITE_OK {
            print("Error opening database.")
        }
    }

    private func createTables() {
        let createMemberTable = """
        CREATE TABLE IF NOT EXISTS Members (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        );
        """

        let createBookTable = """
        CREATE TABLE IF NOT EXISTS Books (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            title TEXT NOT NULL,
            author TEXT NOT NULL
        );
        """

        let createCategoryTable = """
        CREATE TABLE IF NOT EXISTS Categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL
        );
        """

        let createBookCategoryTable = """
        CREATE TABLE IF NOT EXISTS BookCategory (
            bookID INTEGER NOT NULL,
            categoryID INTEGER NOT NULL,
            PRIMARY KEY (bookID, categoryID),
            FOREIGN KEY (bookID) REFERENCES Books(id) ON DELETE CASCADE,
            FOREIGN KEY (categoryID) REFERENCES Categories(id) ON DELETE CASCADE
        );
        """

        let createBorrowingsTable = """
        CREATE TABLE IF NOT EXISTS Borrowings (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            memberID INTEGER NOT NULL,
            bookID INTEGER NOT NULL,
            borrowDate TEXT NOT NULL,
            returnDate TEXT NOT NULL,
            returned BOOLEAN NOT NULL,
            FOREIGN KEY (memberID) REFERENCES Members(id) ON DELETE CASCADE,
            FOREIGN KEY (bookID) REFERENCES Books(id) ON DELETE CASCADE
        );
        """

        executeSQL(createMemberTable)
        executeSQL(createBookTable)
        executeSQL(createCategoryTable)
        executeSQL(createBookCategoryTable)
        executeSQL(createBorrowingsTable)
    }

    func executeSQL(_ sql: String) {
        var statement: OpaquePointer?
        if sqlite3_prepare_v2(db, sql, -1, &statement, nil) == SQLITE_OK {
            if sqlite3_step(statement) != SQLITE_DONE {
                print("Failed to execute SQL: \(sql)")
            }
        } else {
            print("Error preparing statement: \(String(cString: sqlite3_errmsg(db)))")
        }
        sqlite3_finalize(statement)
    }

    deinit {
        sqlite3_close(db)
    }
}
