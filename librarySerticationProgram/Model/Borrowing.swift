//
//  Borrowing.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import Foundation

// Model untuk Peminjaman
struct Borrowing: Identifiable {
    var id: Int32
    var memberID: Int32
    var bookID: Int32
    var borrowDate: String
    var returnDate: String
    var returned: Bool
}
