//
//  EditBookView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//
import SwiftUI

struct EditBookView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var categoryVM: CategoryViewModel
    @ObservedObject var bookVM: BookViewModel
    
    let book: Book
    
    @State private var title: String
    @State private var author: String
    @State private var categories: [Category]
    
    init(_ book: Book, categoryVM: CategoryViewModel, bookVM: BookViewModel) {
        self.book = book
        self.categoryVM = categoryVM
        self.bookVM = bookVM
        
        self.title = book.title
        self.author = book.author
        self.categories = book.categories
    }
    
    var disabled: Bool {
        return title.trimmingCharacters(in: .whitespaces).isEmpty || author.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            Section(header: Text("Book Details")) {
                TextField("Title", text: $title)
                TextField("Author", text: $author)
            }
            Section(header: Text("Categories")) {
                ForEach(categoryVM.categories) { category in
                    HStack {
                        Text(category.name)
                        Spacer()
                        if categories.first(where: { $0.id == category.id }) != nil {
                            Image(systemName: "checkmark")
                        }
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if let index = categories.firstIndex(where: { $0.id == category.id }) {
                            categories.remove(at: index)
                        } else {
                            categories.append(category)
                        }
                    }
                }
            }
        }
        .navigationTitle("Edit Book")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    bookVM.updateBook(
                        bookID: book.id,
                        title: title,
                        author: author,
                        categoryIDs: categories.map { $0.id }
                    )
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(disabled)
            }
        }
    }
}
