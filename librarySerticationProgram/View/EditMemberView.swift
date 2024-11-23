//
//  EditMemberView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

struct EditMemberView: View {
    @Environment(\.presentationMode) var presentationMode
    
    @ObservedObject var memberVM: MemberViewModel
    
    let member: Member
    
    @State private var name: String
    
    init(_ member: Member, memberVM: MemberViewModel) {
        self.member = member
        self.memberVM = memberVM
        
        self.name = member.name
    }
    
    var disabled: Bool {
        return name.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        Form {
            TextField("Name", text: $name)
        }
        .navigationTitle("Edit Member")
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Save") {
                    if !name.trimmingCharacters(in: .whitespaces).isEmpty {
                        memberVM.updateMember(id: member.id, name: name)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                .disabled(disabled)
            }
        }
    }
}
