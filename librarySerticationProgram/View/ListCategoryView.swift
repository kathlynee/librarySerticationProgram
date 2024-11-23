//
//  ListCategoryView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

struct ListCategoryView: View {
    @StateObject private var categoryVM = CategoryViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(categoryVM.categories) { category in
                    NavigationLink {
                        EditCategoryView(
                            category,
                            categoryVM: categoryVM
                        )
                    } label: {
                        VStack(alignment: .leading) {
                            Text(category.name)
                                .font(.headline)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let category = categoryVM.categories[index]
                        categoryVM.deleteCategory(id: category.id)
                    }
                }
            }
            .navigationTitle("Categories")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddCategoryView(categoryVM: categoryVM))
                }
            }
        }
        .onAppear {
            categoryVM.fetchCategories()
        }
    }
}
