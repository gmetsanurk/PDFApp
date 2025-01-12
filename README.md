# PDFApp

**PDFApp** is an iOS application designed to simplify creating, editing, managing, and sharing PDF documents. 
---

## Features

### 1. Welcome Screen
- A user-friendly welcome screen provides a brief overview of the application's functionality.

### 2. PDF Document Generation
- **File Importing**: Add photos from the gallery or import files in popular formats from the file system.
- **PDF Conversion**: Convert selected files and photos into a PDF document.
- **PDF Viewer**: View generated PDFs in a built-in reader.
- **Sharing PDFs**: Share generated documents with others via a share sheet.
- **PDF Editing**: Delete specific pages from a PDF document using intuitive gestures and buttons.

### 3. Saved PDFs Management
- **PDFs List**: View all saved PDF documents on a dedicated screen.
    - Each document displays:
        - **Title**
        - **File Extension**
        - **Creation Date**
        - **Thumbnail Preview**
- **Interactions**:
    - **Single Tap**: Opens the PDF in the reader view.
    - **Long Press Context Menu**:
        - Share the document.
        - Delete the document.
        - Merge documents: Select an additional PDF to combine with the first one. The app creates a new merged document while preserving the originals.

---

## Core Requirements
- **Minimum iOS Version**: iOS 15.
- **User Interface Framework**: SwiftUI.
- **Architecture**: MVVM (Model-View-ViewModel).
- **Navigation**: Standard NavigationView-based navigation.
- **Database**: Realm local storage.

---

Feel free to use this app. You are welcome!
