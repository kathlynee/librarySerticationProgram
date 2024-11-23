//
//  Book.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import Foundation


struct Book: Identifiable {
    var id: Int32
    var title: String
    var author: String
    var categories: [Category] = [] // Relasi Many-to-Many dengan Category
}
