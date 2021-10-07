//
//  TestView.swift
//  BookMark (Not)
//
//  Created by Matthew Burton on 10/09/2021.
//

import Foundation
import SwiftUI
import SwiftExec
import FileWatcher


struct ListView: View {

    @State var fileOnePath = ""
    @State  var fileTwoPath = ""
    @State  var excludeList = ""
    @State  var message = ""
    @State  var messageHeader = ""
    @State  var watchedStatus = "Watching: "
    @State var pushActive = true
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest( sortDescriptors: [] ) var items : FetchedResults<Item>
    let fileManager = FileManager.default

    var body: some View {
        if (watchedStatus != "Watching: "){
            Text(watchedStatus)
        }
        NavigationView() {
            VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10, content: {
                Spacer()
                    List(items) { singleItem in
                            NavigationLink(
                               destination: EditView(singleItem : singleItem),
                               label: {
                                    Image("termianalicon")
                                    Text(singleItem.name!)
                                           .font(.subheadline)
                                           .foregroundColor(Color.white)
                                        .padding(.leading,0)
                                   })
                        Button(action: { testExec(chosenItem: singleItem) }) {
                            Label("Sync", systemImage: "plus")
                        }
                        
                        Button(action: { startWatch(chosenItem: singleItem) }) {
                            Label("Watch", systemImage: "plus")
                        }

                            
                        }.frame(width: 400)
                
                NavigationLink(destination:
                                TerminalMessage(message: self.message, messageHeader: self.messageHeader, watchedStatus: self.watchedStatus),
                   isActive: self.$pushActive) {
                     EmptyView()
                }.hidden()
             
                
                NavigationLink(
                       destination: AddView(),
                       label: {
                           Text("Add New")
                       })
                Spacer()
            })
            }
    }
    func startWatch(chosenItem : Item) {
        self.pushActive = true
        self.watchedStatus =   self.watchedStatus + ", " + chosenItem.name!
        print(self.watchedStatus)
        let filewatcher = FileWatcher([NSString(string: chosenItem.filePathOne!).expandingTildeInPath])

        filewatcher.callback = { event in
            testExec(chosenItem: chosenItem)
        }

        filewatcher.start() // start monitoring
    }
    func testExec(chosenItem : Item) {
        self.pushActive = true
        self.message = "Working..."
        self.messageHeader = "Synced the following files:"
      
        var isDir : ObjCBool = false
        let fileOne = chosenItem.filePathOne!.replacingOccurrences(of:  #"\ "#, with: " ") //Replace Backslashes to get proper path names
        let fileTwo = chosenItem.filePathTwo!.replacingOccurrences(of:  #"\ "#, with: " ") //Replace Backslashes to get proper path names

        if (chosenItem.filePathOne != "None" &&  chosenItem.filePathTwo != "None") {
            if fileManager.fileExists(atPath: fileOne, isDirectory:&isDir) {
                if fileManager.fileExists(atPath: fileTwo, isDirectory:&isDir) {
                    do {
                        let result = try execBash("rsync -ahi --out-format='%n' --exclude 'file.txt' \(chosenItem.filePathOne!)  \(chosenItem.filePathTwo!) --delete")
                    
                        if(result.stdout! != "" && result.stdout! != " " ) {
                            self.messageHeader = "Synced the following files:"
                            self.message = String(result.stdout!)
                        } else {
                            self.message = "All Files Up to date"
                        }
                        
                    } catch {
                        let error = error as! ExecError
                            print(error.execResult)
                    }
                } else {
                    print(fileManager.fileExists(atPath: chosenItem.filePathTwo!, isDirectory:&isDir))
                    self.message = "Backup folder does not exist..."
                }
            } else {
                // file does not exist
                self.message = "Target folder does not exist..."
            }
           
        }
        else {
            self.message = "Please choose both paths."
//            self.showingAlert = true
        }
       
    }

    
}
////
//struct ListView_Previews: PreviewProvider {
//    static var previews: some View {
//        ListView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
//    }
//}
