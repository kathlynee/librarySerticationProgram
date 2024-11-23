//
//  ListBorrowingView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

struct ListBorrowingView: View {
    @StateObject private var borrowingVM = BorrowingViewModel()
    @StateObject private var bookVM = BookViewModel()
    @StateObject private var memberVM = MemberViewModel()
    
    @State private var borrowDate = ""
    @State private var returnDate = ""
    
    @State private var filteredBorrowings: [Borrowing] = []
    @State private var selectedMemberID: Int32? = nil

    var body: some View {
        NavigationView {
            List {
                Picker("Filter by member", selection: $selectedMemberID) {
                    Text("Select one").tag(nil as Int32?)
                    ForEach(memberVM.members) { member in
                        Text(member.name).tag(member.id)
                    }
                }
                ForEach(filteredBorrowings) { borrowing in
                    HStack {
                        VStack(alignment: .leading) {
                            if let book = bookVM.books.first(where: { $0.id == borrowing.bookID }) {
                                Text(book.title).font(.headline)
                            }
                            if let member = memberVM.members.first(where: { $0.id == borrowing.memberID }) {
                                Text(member.name).font(.subheadline)
                            }
                            Text("\(borrowing.borrowDate) until \(borrowing.returnDate)")
                                .font(.subheadline)
                            Text(borrowing.returned ? "Returned" : "Not yet returned")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        Spacer()
                        if !borrowing.returned {
                            Button("Return") {
                                borrowingVM.returnBook(borrowing: borrowing)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Borrowings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        "Add",
                        destination: AddBorrowingView(borrowingVM: borrowingVM, memberVM: memberVM)
                            .onDisappear {
                                selectedMemberID = nil
                                borrowingVM.fetchBorrowings()
                                filteredBorrowings = borrowingVM.borrowings
                            }
                    )
                }
            }
            .onAppear {
                borrowingVM.fetchBorrowings()
                bookVM.fetchBooks()
                memberVM.fetchMembers()
                
                filteredBorrowings = borrowingVM.borrowings
            }
            .onChange(of: selectedMemberID) {
                if let id = selectedMemberID {
                    filteredBorrowings = borrowingVM.borrowings.filter {
                        !$0.returned && $0.memberID == id
                    }
                } else {
                    filteredBorrowings = borrowingVM.borrowings
                }
            }
        }
    }
}
