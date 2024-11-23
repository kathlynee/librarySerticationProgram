//
//  BorrowingViewModel.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import Foundation
import SQLite3

class BorrowingViewModel: ObservableObject {
    @Published var borrowings: [Borrowing] = []
    @Published var members: [Member] = []
    @Published var books: [Book] = []
    @Published var detailedBorrowings: [(borrowing: Borrowing, memberName: String, bookTitle: String)] = []
    @Published var selectedBorrowing: Borrowing? = nil

    private let db = DatabaseHelper.shared

    // Fetch all borrowings
    func fetchBorrowings() {
        borrowings.removeAll()
        let sql = "SELECT id, memberID, bookID, borrowDate, returnDate, returned FROM Borrowings;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = sqlite3_column_int(stmt, 0)
                let memberID = sqlite3_column_int(stmt, 1)
                let bookID = sqlite3_column_int(stmt, 2)
                let borrowDate = String(cString: sqlite3_column_text(stmt, 3))
                let returnDate = String(cString: sqlite3_column_text(stmt, 4))
                let returned = sqlite3_column_int(stmt, 5)
                borrowings.append(
                    Borrowing(
                        id: id,
                        memberID: memberID,
                        bookID: bookID,
                        borrowDate: borrowDate,
                        returnDate: returnDate,
                        returned: returned == 1
                    )
                )
            }
        }
        
        borrowings.sort {
            let a = parseDate($0.borrowDate) ?? .now
            let b = parseDate($1.borrowDate) ?? .now
            return a > b
        }
        
        sqlite3_finalize(stmt)
    }

    // Fetch members
    func fetchMembers() {
        let memberVM = MemberViewModel()
        memberVM.fetchMembers()
        members = memberVM.members
    }

    // Fetch available books (only books not currently borrowed)
    func fetchAvailableBooks() {
        let bookVM = BookViewModel()
        bookVM.fetchBooks()
        books = bookVM.books.filter { book in
            guard let borrowing = borrowings.first(where: { $0.bookID == book.id }) else {
                return true
            }
            
            return borrowing.returned
        }
    }

    // Fetch borrowings for a specific member
    func fetchBorrowingsByMember(memberID: Int32) -> [Borrowing] {
        return borrowings.filter { $0.memberID == memberID }
    }

    // Fetch borrowing information for a specific book
    func fetchBorrowingsByBook(bookID: Int32) -> Borrowing? {
        return borrowings.first { $0.bookID == bookID && $0.returnDate.isEmpty }
    }

    // Add new borrowing
    func addBorrowing(memberID: Int32, bookID: Int32, borrowDate: String, returnDate: String) {
        let sql = "INSERT INTO Borrowings (memberID, bookID, borrowDate, returnDate, returned) VALUES (?, ?, ?, ?, ?);"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, memberID)
            sqlite3_bind_int(stmt, 2, bookID)
            sqlite3_bind_text(stmt, 3, (borrowDate as NSString).utf8String, -1, nil)
            sqlite3_bind_text(stmt, 4, (returnDate as NSString).utf8String, -1, nil)
            sqlite3_bind_int(stmt, 5, 0)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("STATEMENT SUCCESS")
            } else {
                print("STATEMENT FAILED")
            }
        }
        sqlite3_finalize(stmt)
        fetchBorrowings()
    }

    // Update borrowing
    func returnBook(borrowing: Borrowing) {
        let sql = "UPDATE Borrowings SET returned = ? WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, 1)
            sqlite3_bind_int(stmt, 2, borrowing.id)
            if sqlite3_step(stmt) == SQLITE_DONE {
                print("STATEMENT SUCCESS")
            } else {
                print("STATEMENT FAILED")
            }
        }
        sqlite3_finalize(stmt)
        fetchBorrowings()
    }

    // Check if a book is available
    func isBookAvailable(bookID: Int32) -> Bool {
        return !borrowings.contains { $0.bookID == bookID && $0.returnDate.isEmpty }
    }

    // Delete borrowing
    func deleteBorrowing(id: Int32) {
        let sql = "DELETE FROM Borrowings WHERE id = ?;"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db.db, sql, -1, &stmt, nil) == SQLITE_OK {
            sqlite3_bind_int(stmt, 1, id)
            sqlite3_step(stmt)
        }
        sqlite3_finalize(stmt)
        fetchBorrowings()
    }

    // Fetch borrowings with member names and book titles
    func fetchBorrowingsWithDetails() {
        fetchBorrowings()
        fetchMembers()
        fetchAvailableBooks()

        detailedBorrowings = borrowings.map { borrowing in
            let memberName = members.first { $0.id == borrowing.memberID }?.name ?? "Unknown Member"
            let bookTitle = books.first { $0.id == borrowing.bookID }?.title ?? "Unknown Book"
            return (borrowing, memberName, bookTitle)
        }
    }
    
    func parseDate(_ rawDate: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"

        return dateFormatter.date(from: rawDate)
    }
}
