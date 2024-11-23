//
//  ListMemberView.swift
//  librarySerticationProgram
//
//  Created by Kathlyne Sarah on 23/11/24.
//

import SwiftUI

struct ListMemberView: View {
    @StateObject private var memberVM = MemberViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(memberVM.members) { member in
                    NavigationLink {
                        EditMemberView(
                            member,
                            memberVM: memberVM
                        )
                    } label: {
                        VStack(alignment: .leading) {
                            Text(member.name)
                                .font(.headline)
                        }
                    }
                }
                .onDelete { indexSet in
                    indexSet.forEach { index in
                        let member = memberVM.members[index]
                        memberVM.deleteMember(id: member.id)
                    }
                }
            }
            .navigationTitle("Members")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddMemberView(memberVM: memberVM))
                }
            }
        }
        .onAppear {
            memberVM.fetchMembers()
        }
    }
}
