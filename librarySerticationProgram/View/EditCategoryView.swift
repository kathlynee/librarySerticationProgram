//
//  EditBookView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//
import SwiftUI

struct EditCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var categoryVM: CategoryViewModel
    
    let category: Category
    
    @State private var name: String
    
    init(_ category: Category, categoryVM: CategoryViewModel) {
        self.category = category
        self.categoryVM = categoryVM
        
        self.name = category.name
    }
    
    var disabled: Bool {
        return name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle("Edit Category")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        categoryVM.updateCategory(id: category.id, name: name)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(disabled)
            }
        }
    }
}
