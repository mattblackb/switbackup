//
//  AddView.swift
//  Core Data
//
//  Created by Matthew Burton on 23/07/2021.
//

import SwiftUI

struct AddView: View {
    
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest( sortDescriptors: [] ) var items : FetchedResults<Item>

    @State var pname = ""
    @State var pdesc = ""
    @State var plink = ""
    @State var warning = ""
    @State private var alertShowing = false
    @State var fileOnePath = ""
    @State  var fileTwoPath = ""
    @State  var excludeList = ""
    
    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing:0, content: {
                
                VStack(content: {Text("Add new item")
                        .padding(20)
                        .foregroundColor(.gray)
                        .font(/*@START_MENU_TOKEN@*/.title/*@END_MENU_TOKEN@*/)
              
                    if warning != "" {
                        Text(self.warning)
                            .foregroundColor(.red)
                            .padding(.leading,  20)
                            .font(.title)
                    }
                    
                    Text("Display Name")
                        .padding(.leading, 20)
                        
                
                    TextField("", text: $pname, onCommit: {
                      
                    }).padding(20)
                })
                    
                
                Text("Exclude List (comma seperated")
                    .padding(.leading, 20)
                    
            
                    TextField("", text: $excludeList, onCommit: {
                      
                    }).padding(20)
                
                Text("Target Path:" + fileOnePath)
                Text("fileTwoPath:" + fileTwoPath)
                Button("Choose Folder One") {
                    self.selectFolder(selfVar: "filePathOne")
                
                }
                Button("Choose Folder Two") {
                    self.selectFolder(selfVar: "filePathTwo")
                
                }
           
                    Button(action: addItem, label: {
                        Text("Save")
                    })
                    .padding(.leading, 20)
                    
                    
                    Spacer()            })
     
          
            
        }
    }
    
    
    
    private func addItem() {
        if(self.fileOnePath == "" || self.fileOnePath == "null"){
            self.warning =  "Please set a Target link!"
        } else if (self.fileTwoPath == "" || self.fileTwoPath == "null"){
            self.warning =  "Please set a Destination Link!"
        } else {
            let p = Item(context: viewContext)
            p.name = self.pname
            p.excludeList = self.excludeList
            p.filePathOne = self.fileOnePath
            p.filePathTwo = self.fileTwoPath
//            print("Not Linlk"+self.plink)
            do {
                try  viewContext.save()
            }
            catch {
                let nsError = error as NSError
              fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
        self.pname = ""
        self.fileOnePath = ""
        self.fileTwoPath = ""
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



//struct AddView_Previews: PreviewProvider {
//    static var previews: some View {
//        AddView()
//    }
//}
