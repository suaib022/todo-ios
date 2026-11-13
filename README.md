# 👾 Mobile Computing Lab Assignment: Firebase Integrated Todo List App

**Project Name:** `todo-ios`  
**Technology Stack:** Swift, SwiftUI, FirebaseCore, FirebaseAuth, FirebaseFirestore  
**Architecture:** Model-View-ViewModel (MVVM)

---

## 📌 Features & Assignment Requirements

1. **Task Title & Description**:
   - Each task contains a `title`, `description`, `isCompleted` status, `priority` (High, Medium, Low), and `createdAt` timestamp.
2. **Full CRUD Operations**:
   - **Create**: Add new tasks with title, description, and priority level.
   - **Read**: Live real-time synchronized task list with filter tabs (All, Pending, Done).
   - **Update**: Edit existing tasks or tap the checkmark to mark tasks complete or incomplete.
   - **Delete**: Swipe left on any task to delete it from Cloud Firestore.
3. **Firebase Authentication**:
   - User sign-up / registration with email & password (validation: minimum 6 characters, password confirmation).
   - User sign-in & sign-out.
   - Session state preserved across app launches.
4. **Cloud Firestore Storage**:
   - Tasks are stored in the Firestore `tasks` collection.
   - Every task is tagged with the user's unique Firebase UID (`userId`).
   - Each user can only view, edit, and delete their own tasks.

---

## 📁 Project Structure

```
todo-ios/
├── todo-ios.xcodeproj               # Xcode project file
└── todo-ios/
    ├── TodoApp.swift                 # App entry point (@main, FirebaseApp.configure())
    ├── GoogleService-Info.plist.example # Firebase configuration template
    ├── Models/
    │   └── TodoItem.swift            # Data model (Identifiable, Codable)
    ├── Services/
    │   ├── AuthenticationManager.swift # Firebase Auth service (async/await)
    │   └── TodoDatabaseManager.swift   # Cloud Firestore CRUD operations
    ├── ViewModels/
    │   ├── AuthViewModel.swift       # Sign-in/sign-up state & validation
    │   └── TodoListViewModel.swift   # Task filtering, real-time sync & operations
    └── Views/
        ├── RootCoordinatorView.swift # Switches between Auth and Dashboard
        ├── SignInView.swift          # Login screen
        ├── SignUpView.swift          # Registration screen
        ├── TaskDashboardView.swift   # Main dashboard with filter bar
        ├── TaskCardRow.swift         # Custom modern card component
        └── AddEditTaskSheet.swift    # Modal form for create & edit
```

---

## ⚙️ Firebase Console Setup Instructions

1. **Authentication**:
   - Go to [Firebase Console](https://console.firebase.google.com/) -> **Build -> Authentication -> Sign-in method**.
   - Enable **Email/Password**.

2. **Cloud Firestore Database**:
   - Go to **Build -> Firestore Database** and click **Create Database**.
   - In the **Rules** tab, publish these security rules:
     ```javascript
     rules_version = '2';
     service cloud.firestore {
       match /databases/{database}/documents {
         match /tasks/{taskId} {
           allow create: if request.auth != null
                         && request.auth.uid == request.resource.data.userId;

           allow read, delete: if request.auth != null
                               && request.auth.uid == resource.data.userId;

           allow update: if request.auth != null
                         && request.auth.uid == resource.data.userId
                         && request.auth.uid == request.resource.data.userId;
         }
       }
     }
     ```

---

## 🚀 How to Run in Xcode

1. Open `todo-ios.xcodeproj` in Xcode.
2. Select an iOS Simulator (e.g., iPhone 16) as the destination.
3. Press **Cmd + R** (or click the Run button) to build and run the app.

