//
//  ListBookView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

struct ListBookView: View {
    @StateObject private var bookVM = BookViewModel()
    @StateObject private var categoryVM = CategoryViewModel()
    
    @State private var filteredBooks: [Book] = []
    @State private var selectedCategoryID: Int32? = nil

    var body: some View {
        NavigationView {
            List {
                Picker("Filter by category", selection: $selectedCategoryID) {
                    Text("Select one").tag(nil as Int32?)
                    ForEach(categoryVM.categories) { category in
                        Text(category.name).tag(category.id)
                    }
                }
                ForEach(Array(filteredBooks.enumerated()), id: \.offset) { i, book in
                    NavigationLink {
                        EditBookView(
                            book,
                            categoryVM: categoryVM,
                            bookVM: bookVM
                        )
                        .onDisappear {
                            selectedCategoryID = nil
                            bookVM.fetchBooks()
                            filter()
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(book.title)
                                .font(.headline)
                            Text("Author: \(book.author)")
                                .font(.subheadline)
                            Text("Categories: \(book.categories.map { $0.name }.joined(separator: ", "))")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let book = bookVM.books[index]
                        bookVM.deleteBook(bookID: book.id)
                        bookVM.fetchBooks()
                        filter()
                    }
                }
            }
            .navigationTitle("Books")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        "Add",
                        destination: AddBookView(bookVM: bookVM)
                            .onDisappear {
                                selectedCategoryID = nil
                                bookVM.fetchBooks()
                                filter()
                            }
                    )
                }
            }
        }
        .onAppear {
            bookVM.fetchBooks()
            categoryVM.fetchCategories()
            
            filteredBooks = bookVM.books
        }
        .onChange(of: selectedCategoryID) {
            filter()
        }
    }
    
    private func filter() {
        if let id = selectedCategoryID {
            filteredBooks = bookVM.books.filter {
                $0.categories.contains(where: { $0.id == id })
            }
        } else {
            filteredBooks = bookVM.books
        }
    }
}
