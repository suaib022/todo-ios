import Foundation
import FirebaseFirestore

// MARK: - Lab Assignment: Cloud Firestore Database Manager
// TODO: Firebase Console -> Firestore Database e 'tasks' collection er rules publish korte hobe.
// Security Rules:
// rules_version = '2';
// service cloud.firestore {
//   match /databases/{database}/documents {
//     match /tasks/{taskId} {
//       allow create: if request.auth != null && request.auth.uid == request.resource.data.userId;
//       allow read, delete: if request.auth != null && request.auth.uid == resource.data.userId;
//       allow update: if request.auth != null && request.auth.uid == resource.data.userId && request.auth.uid == request.resource.data.userId;
//     }
//   }
// }

/// Manager class responsible for all Cloud Firestore CRUD operations.
class TodoDatabaseManager {
    static let shared = TodoDatabaseManager()

    private let db = Firestore.firestore()
    private let tasksCollection = "tasks"

    private init() {}

    /// CREATE: Adds a new task document to Firestore for the user
    func createTodo(
        title: String,
        description: String,
        priority: String,
        userId: String
    ) async throws {
        let newTodo = TodoItem(
            title: title,
            description: description,
            isCompleted: false,
            priority: priority,
            createdAt: Date(),
            userId: userId
        )
        _ = try db.collection(tasksCollection).addDocument(from: newTodo)
    }

    /// READ: Fetches user's tasks one time (filtered by userId)
    func fetchUserTodos(userId: String) async throws -> [TodoItem] {
        let snapshot = try await db.collection(tasksCollection)
            .whereField("userId", isEqualTo: userId)
            .getDocuments()

        let items = snapshot.documents.compactMap { doc -> TodoItem? in
            try? doc.data(as: TodoItem.self)
        }

        // Sort by newest first
        return items.sorted { $0.createdAt > $1.createdAt }
    }

    /// READ (Real-time): Subscribes to real-time updates for user's tasks
    func subscribeToUserTodos(
        userId: String,
        onUpdate: @escaping (Result<[TodoItem], Error>) -> Void
    ) -> ListenerRegistration {
        return db.collection(tasksCollection)
            .whereField("userId", isEqualTo: userId)
            .addSnapshotListener { snapshot, error in
                if let error = error {
                    onUpdate(.failure(error))
                    return
                }

                guard let docs = snapshot?.documents else {
                    onUpdate(.success([]))
                    return
                }

                let items = docs.compactMap { doc -> TodoItem? in
                    try? doc.data(as: TodoItem.self)
                }.sorted { $0.createdAt > $1.createdAt }

                onUpdate(.success(items))
            }
    }

    /// UPDATE: Updates task title, description, and priority
    func updateTodo(
        id: String,
        title: String,
        description: String,
        priority: String
    ) async throws {
        try await db.collection(tasksCollection).document(id).updateData([
            "title": title,
            "description": description,
            "priority": priority
        ])
    }

    /// UPDATE (Toggle): Toggles task completion state
    func setTodoCompletion(id: String, isCompleted: Bool) async throws {
        try await db.collection(tasksCollection).document(id).updateData([
            "isCompleted": isCompleted
        ])
    }

    /// DELETE: Removes task document from Firestore
    func removeTodo(id: String) async throws {
        try await db.collection(tasksCollection).document(id).delete()
    }
}

