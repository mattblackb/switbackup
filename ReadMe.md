# Building an iOs app that uses Rysync to sync folders in SwiftUI

Goals - Allow the user to choose two folders on their Macs, save these folder paths to CoreData, add a name, folder exemption list and description  for reference. These database items are displayed in a list with a synchronise button that allows the app to access terminal and use rsync to sync data between these two folder paths, excluding the exception list folders.

Future dev. - Add database field to store watched folders - so that the process can be automated on save of a file. Add menu item and Launch art login facility.

## Reasons to build
One of the problems developers have is backing up folders of app data that contain folders that contain multiple files that are not needed for backup purposes - folders such as node_modules that can be rebuilt on a need to use basis.

## Issues to overcome
App cannot be sandboxed as the terminal commands cannot be run under sandboxed conditions - making the app unavailable for App Store submission.  Switching off App Sandbox and I haven’t found an issue

## Extensions used
Currently using the excellent SwiftExec - [GitHub - samuelmeuli/swift-exec: Simple process execution with Swift](https://github.com/samuelmeuli/swift-exec)  Rather than process to speed up development of Terminal commands.

## Installation
To do
## 
## Development
### Initial setup and testing
I decided to make a simple test that allowed me to pick two folders and a button to test rsync  Terminal commands.

**Steps:**
**First:** Create function for on window selection of a Folder
```
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
```
This uses [Apple Developer Documentation](https://developer.apple.com/documentation/appkit/nsopenpanel) **NSOpenPanel** to open a folder selection - we make sure that the user can only pick a folder:
` folderPicker.canChooseFiles = false`
And can only  pick one folder
`  folderPicker.allowsMultipleSelection = false`

The real issue I had to overcome here is the creation of a correct path from the chosen path - first the absoluteString returns a file name with two issues - the start of the path has the string file: - which isn’t needed  and secondly the string is returned with spaces as ‘%20’ .

So the first part is easy enough - just take the  first seven characters from the start of the file and get rid of them. With this solved I presumed the second would be as easy just replace %20 with ‘\ ‘ to get the correct path. Unfortunately this function shows an error in SwiftUI as it sees the \ as part of it’s concatenation pattern. To resolve this I wrapped the \ in # as per:

` let replaced = returnedString.replacingOccurrences(of: "%20", with: #"\ "#)`

Took some working out…..

**Second**
**Function to execute rsync**
   First simple function:
```
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
```

The two file paths are saved to a state variables in the folder select function and in the testExec function pulled into the SwiftExec file command as:

` let result = try execBash("rsync -ahi \(self.fileOnePath)  \(self.fileTwoPath)")`

And with a bit of SwiftUI button layout and it works pretty well

Git branch for this test -
https://github.com/mattblackb/switbackup/tree/inital_tests




