//
//  BookViewModel.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import Foundation
import SQLite3

class BookViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var categories: [Category] = []

    private let db = DatabaseHelper.shared

    func fetchBooks() {
        books.removeAll()
        let sql = "SELECT id, title, author FROM Books;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let title = String(cString: sqlite3_column_text(stmt, 1))
                let author = String(cString: sqlite3_column_text(stmt, 2))
                let categories = fetchCategoriesForBook(bookID: id)
                let book = Book(id: id, title: title, author: author, categories: categories)
                print(book)
                books.append(book)
            }
        }
        sqlite3_finalize(stmt)
    }

    func fetchCategories() {
        let categoryVM = CategoryViewModel()
        categoryVM.fetchCategories()
        categories = categoryVM.categories
    }

    func fetchCategoriesForBook(bookID: Int32) -> [Category] {
        var categories: [Category] = []
        let sql = """
        SELECT c.id, c.name FROM Categories c
        JOIN BookCategory bc ON c.id = bc.categoryID
        WHERE bc.bookID = ?;
        """
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, bookID)
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let name = String(cString: sqlite3_column_text(stmt, 1))
                categories.append(Category(id: id, name: name))
            }
        }
        sqlite3_finalize(stmt)
        return categories
    }

    func addBook(title: String, author: String, categoryIDs: [Int32]) {
        guard !title.isEmpty && !author.isEmpty else { return }
        let sql = "INSERT INTO Books (title, author) VALUES (?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (author as NSString).utf8String, -1, nil)
            sqlite3_step(stmt)
            let bookID = Int32(sqlite3_last_insert_rowid(db.db))
            categoryIDs.forEach { assignCategoryToBook(bookID: bookID, categoryID: $0) }
        }
        sqlite3_finalize(stmt)
        fetchBooks()
    }

    func assignCategoryToBook(bookID: Int32, categoryID: Int32) {
        let sql = "INSERT INTO BookCategory (bookID, categoryID) VALUES (?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, bookID)
            sqlite3_bind_int(stmt, 2, categoryID)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func updateBook(bookID: Int32, title: String, author: String, categoryIDs: [Int32]) {
        guard !title.isEmpty && !author.isEmpty else { return }
        let sql = "UPDATE Books SET title = ?, author = ? WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_text(stmt, 1, (title as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 2, (author as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 3, bookID)
            sqlite3_step(stmt)
            removeCategoriesFromBook(bookID: bookID)
            categoryIDs.forEach { assignCategoryToBook(bookID: bookID, categoryID: $0) }
        }
        sqlite3_finalize(stmt)
        fetchBooks()
    }

    func removeCategoriesFromBook(bookID: Int32) {
        let sql = "DELETE FROM BookCategory WHERE bookID = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, bookID)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
    }

    func deleteBook(bookID: Int32) {
        let sql = "DELETE FROM Books WHERE id = ?;"
        var stmt: OpaquePointer?

        print("DELETING BOOK")
        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            print("SQLITE PREPARED")
            sqlite3_bind_int(stmt, 1, bookID)
            
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("STATEMENT SUCCESS")
            } else {
                print("STATEMENT FAILED")
            }
        }
        let deleted_id = sqlite3_finalize(stmt)
        print("DELETED: \(deleted_id)")
        fetchBooks()
    }
}
