//
//  AddMemberView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI


struct AddMemberView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var memberVM: MemberViewModel
    
    @State private var name: String = ""
    
    var disabled: Bool {
        return name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle("Add Member")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        memberVM.addMember(name: name)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(disabled)
            }
        }
    }
}

