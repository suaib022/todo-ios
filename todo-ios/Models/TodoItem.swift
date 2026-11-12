import Foundation
import FirebaseFirestore

// MARK: - Lab Assignment: Task Model
// Description: Represents a single Todo item stored in Cloud Firestore.
// Fields: title, description, isCompleted, priority, createdAt, userId.

/// Data model for a task item in Safi's Todo List App.
struct TodoItem: Identifiable, Codable {
    @DocumentID var id: String?
    var title: String
    var description: String
    var isCompleted: Bool
    var priority: String        // "High", "Medium", or "Low"
    var createdAt: Date
    var userId: String

    init(
        id: String? = nil,
        title: String,
        description: String = "",
        isCompleted: Bool = false,
        priority: String = "Medium",
        createdAt: Date = Date(),
        userId: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.isCompleted = isCompleted
        self.priority = priority
        self.createdAt = createdAt
        self.userId = userId
    }
}

// Priority helper enum for easy UI styling
enum TaskPriority: String, CaseIterable, Identifiable {
    case high = "High"
    case medium = "Medium"
    case low = "Low"

    var id: String { rawValue }
}

