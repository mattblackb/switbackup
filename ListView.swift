//
//  TestView.swift
//  BookMark (Not)
//
//  Created by Matthew Burton on 10/09/2021.
//

import Foundation
import SwiftUI
import SwiftExec


struct ListView: View {

    
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest( sortDescriptors: [] ) var items : FetchedResults<Item>

    var body: some View {
        NavigationView() {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10, content: {
                List(items) { singleItem in
                        NavigationLink(
                           destination: EditView(person : singleItem),
                           label: {
                               Image("termianalicon")
                            Text(singleItem.name!+"Name")
                                   .font(.subheadline)
                                   .foregroundColor(Color.white)
                                .padding(.leading,0)
                           })
                        
                    }.frame(width: 400)
        
                
         
            
            NavigationLink(
                                       destination: AddView(),
                                       label: {
                                           Text("Add New")
                                       })
 
        })

        }
    }
          

    
}
////
//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
