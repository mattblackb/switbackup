//
//  BookMark__Not_App.swift
//  BookMark (Not)
//
//  Created by Matthew Burton on 10/09/2021.
//

import SwiftUI

@main
struct BookMark__Not_App: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            TestView(fileOnePath: "none", fileTwoPath: "none")
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
