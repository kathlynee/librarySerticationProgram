//
//  AddCategoryView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 24/11/24.
//

import SwiftUI

struct AddCategoryView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var categoryVM: CategoryViewModel
    
    @State private var name: String = ""
    
    var disabled: Bool {
        return name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle("Add Category")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        categoryVM.addCategory(name: name)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(disabled)
            }
        }
    }
}

