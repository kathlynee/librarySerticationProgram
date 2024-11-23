//
//  AddBookView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

struct AddBookView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var bookVM: BookViewModel
    
    @State private var title: String = ""
    @State private var author: String = ""
    @State private var categories: [Category] = []
    
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
                ForEach(bookVM.categories) { category in
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
        .navigationTitle("Add Book")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if !title.trimmingCharacters(in: .whitespaces).isEmpty && !author.trimmingCharacters(in: .whitespaces).isEmpty {
                        bookVM.addBook(
                            title: title,
                            author: author,
                            categoryIDs: categories.map { $0.id }
                        )
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Error: Title or Author cannot be empty.")
                    }
                }
                .disabled(disabled)
            }
        }
        .onAppear {
            bookVM.fetchCategories()
        }
    }
}
