//
//  AddBorrowingView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

struct AddBorrowingView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var borrowingVM: BorrowingViewModel
    @ObservedObject var memberVM: MemberViewModel
    
    @State private var selectedMemberID: Int32? = nil
    @State private var selectedBookID: Int32? = nil
    @State private var borrowDate = Date()
    @State private var returnDate = Date()
    
    var disabled: Bool {
        return selectedMemberID == nil || selectedBookID == nil || borrowDate >= returnDate
    }

    var body: some View {
        Form {
            Section(header: Text("Select Member")) {
                Picker("Member", selection: $selectedMemberID) {
                    Text("Select one").tag(nil as Int32?)
                    ForEach(memberVM.members) { member in
                        Text(member.name).tag(member.id as Int32?)
                    }
                }
            }

            Section(header: Text("Select Book")) {
                Picker("Book", selection: $selectedBookID) {
                    Text("Select one").tag(nil as Int32?)
                    ForEach(borrowingVM.books) { book in
                        Text(book.title).tag(book.id as Int32?)
                    }
                }
            }

            Section(header: Text("Borrow Date")) {
                DatePicker("Borrow Date", selection: $borrowDate, displayedComponents: .date)
            }

            Section(header: Text("Return Date")) {
                DatePicker("Return Date", selection: $returnDate, displayedComponents: .date)
            }
        }
        .navigationTitle("Add Borrowing")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if let memberID = selectedMemberID, let bookID = selectedBookID {
                        borrowingVM.addBorrowing(
                            memberID: memberID,
                            bookID: bookID,
                            borrowDate: formatDate(borrowDate),
                            returnDate: formatDate(returnDate)
                        )
                        presentationMode.wrappedValue.dismiss()
                    } else {
                        print("Error: Member or Book not selected.")
                    }
                }
                .disabled(disabled)
            }
        }
        .onAppear {
            memberVM.fetchMembers()
            borrowingVM.fetchAvailableBooks()
        }
    }

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
}

extension Binding {
    init(_ source: Binding<Value?>, replacingNilWith defaultValue: Value) {
        self.init(
            get: { source.wrappedValue ?? defaultValue },
            set: { source.wrappedValue = $0 }
        )
    }
}
