//
//  TestView.swift
//  BookMark (Not)
//
//  Created by Matthew Burton on 10/09/2021.
//

import Foundation
import SwiftUI
import SwiftExec


struct TestView: View {

    @State var fileOnePath: String
    @State var fileTwoPath: String
    @State private var showingAlert = false
    @State private var message  = "Error!!!"
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest( sortDescriptors: [] ) var items : FetchedResults<Item>


    var body: some View {
        VStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/, spacing: 10, content: {
        
            ListView() 
            
            Text("fileOnePath:" + fileOnePath)
            Text("fileTwoPath:" + fileTwoPath)
            Button("Choose Folder One") {
                self.selectFolder(selfVar: "filePathOne")
            
            }
            Button("Choose Folder Two") {
                self.selectFolder(selfVar: "filePathTwo")
            
            }
            Button(action: testExec) {
                Label("Synchronise", systemImage: "plus")
            }
            Button(action: addItems) {
                Label("Add to saved", systemImage: "plus")
            }
        }).padding(10)
        .alert(isPresented: $showingAlert, content: {
            Alert(title: Text("Important message"), message: Text(self.message), dismissButton: .default(Text("Got it!")))
        })
        .frame(width: 1000, alignment: .center)
       
    }
          

    func addItems() {
        let p = Item(context: viewContext)
        print(items)
        p.filePathOne = fileOnePath
        p.filePathTwo = fileTwoPath
        p.name = "Test./."
//            print("Not Linlk"+self.plink)
        do {
            try  viewContext.save()
        }
        catch {
            let nsError = error as NSError
            print("Errro")
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
           
        }
        
        
    }
    
    
    func testExec() {
        if (self.fileOnePath != "None" &&  self.fileTwoPath != "None") {
            do {
                let result = try execBash("rsync -ahi \(self.fileOnePath)  \(self.fileTwoPath)")
                print(result.stdout!)
            } catch {
                let error = error as! ExecError
                    print(error.execResult)
            }
        }
        else {
            self.message = "Please choose both paths."
            self.showingAlert = true
        }
       
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
