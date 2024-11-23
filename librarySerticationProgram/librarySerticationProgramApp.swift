//
//  librarySerticationProgramApp.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

@main
struct LibrarySerticationProgramApp: App {
    var body: some Scene {
        WindowGroup {
            MainView()  // Menggunakan MainView sebagai tampilan utama
        }
    }
}

struct MainView: View {
    var body: some View {
        TabView {
            // Tab untuk Members
            ListMemberView()
                .tabItem {
                    Label("Users", systemImage: "person.3")
                }
            
            // Tab untuk Books
            ListBookView()
                .tabItem {
                    Label("Books", systemImage: "book.fill")
                }
            
            // Tab untuk Categories
            ListCategoryView()
                .tabItem {
                    Label("Categories", systemImage: "tag.fill")
                }
            
            // Tab untuk Borrowings
            ListBorrowingView()
                .tabItem {
                    Label("Borrowings", systemImage: "book.closed.fill")
                }
        }
    }
}
