//
//  EditView.swift
//  BookMark (Not)
//
//  Created by Matthew Burton on 04/10/2021.
//

import SwiftUI
import SwiftExec
import FileWatcher


struct EditView: View {
    
    
    
    @Environment(\.managedObjectContext) private var viewContext
    
    var singleItem: Item
    @State var pname = ""
    @State var fileOnePath = ""
    @State  var fileTwoPath = ""
    @State  var excludeList = ""
    @State  var message = ""
    @State  var messageHeader = ""
    @State  var watchedStatus = ""
    @State var pushActive = true
    
    let fileManager = FileManager.default
    var body: some View {
        Text(watchedStatus).font(.title).padding(20).frame(alignment: .leading )
        VStack(alignment: .leading, spacing: 20, content: {
            HStack(content: {
                Text("Chosen Path: ").padding(.leading, 20)
                Text(self.fileOnePath).onAppear {
                    self.fileOnePath = self.singleItem.filePathOne != nil ? "\(self.singleItem.filePathOne!)" : ""
                }.onChange(of: fileOnePath) { newValue in
                    singleItem.filePathOne  = self.fileOnePath
                    try! viewContext.save()
                }
            })
            HStack(content: {
                Text("Target Path: ").padding(.leading, 20)
                Text(self.fileTwoPath).onAppear {
                    self.fileTwoPath = self.singleItem.filePathTwo != nil ? "\(self.singleItem.filePathTwo!)" : ""
                } .onChange(of: fileTwoPath) { newValue in
                    singleItem.filePathTwo  = self.fileTwoPath
                    try! viewContext.save()
                }
            })
            HStack(content: {
                Text("Display Name").padding(.leading, 20)
                TextField("", text: $pname, onCommit: {
                    singleItem.name = self.pname
                    try! viewContext.save()
                })
                .onAppear {
                    self.pname = self.singleItem.name != nil ? "\(self.singleItem.name!)" : ""
                }
            })
            HStack(content: {
                Text("Excludes")
                    .padding(.leading, 20)
                TextField("", text: $excludeList, onCommit: {
                    singleItem.excludeList = self.excludeList
                    try! viewContext.save()
                })
                .onAppear {
                    self.excludeList = self.singleItem.excludeList != nil ? "\(self.singleItem.excludeList!)" : ""
                }
            })
        
            HStack(content: {
                Button("Choose Folder One") {
                    self.selectFolder(selfVar: "filePathOne")
                }.padding(20)
                Button("Choose Folder Two") {
                    self.selectFolder(selfVar: "filePathTwo")
                
                }.padding(20)
            }).padding(20)
        })
      Button(action: deleteItem) {
          Label("Delete", systemImage: "xmark.bin")
      }.padding(20)
        Button(action: { startWatch(chosenItem: singleItem) }) {
            Label("Watch", systemImage: "plus")
        }

    }
    
    func startWatch(chosenItem : Item) {
        self.pushActive = true
        self.watchedStatus = "Watching:"+chosenItem.name!
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

    private func deleteItem() {
        viewContext.delete(singleItem)
        }
    
    func selectFolder(selfVar : String) {
            var returnedString = ""
            let folderChooserPoint = CGPoint(x: 0, y: 0)
            let folderChooserSize = CGSize(width: 500, height: 600)
            let folderChooserRectangle = CGRect(origin: folderChooserPoint, size: folderChooserSize)
            let folderPicker = NSOpenPanel(contentRect: folderChooserRectangle, styleMask: .utilityWindow, backing: .buffered, defer: true)

            folderPicker.canChooseDirectories = true
            folderPicker.canChooseFiles = false
            folderPicker.allowsMultipleSelection = false
            folderPicker.canDownloadUbiquitousContents = true
            folderPicker.canResolveUbiquitousConflicts = true

            folderPicker.begin { response in
                if response == .OK {
                    let pickedFolders = folderPicker.urls
                        returnedString = pickedFolders[0].absoluteString
                        let replaced = returnedString.replacingOccurrences(of: "%20", with: #"\ "#)
                        returnedString  = String(replaced.dropFirst(7))//Removes file:// from the front of the returned path string
                        if(selfVar == "filePathOne") { //Probably better to return this filepath for easier use in the future.
                            self.fileOnePath = returnedString
                        } else {
                            self.fileTwoPath = returnedString
                        }
                }
            }
        }
    

}



//struct EditView_Previews: PreviewProvider {
//    static var previews: some View {
//        EditView()
//    }
//}
