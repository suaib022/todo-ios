import Foundation
import SwiftUI
import Combine
import FirebaseFirestore

// MARK: - Lab Assignment: Todo List ViewModel (MVVM)
// Connects UI with TodoDatabaseManager; filters tasks, handles real-time updates and errors.

@MainActor
class TodoListViewModel: ObservableObject {
    @Published var todoList: [TodoItem] = []
    @Published var isLoading = false
    @Published var statusError: String?

    // 0: All, 1: Active/Pending, 2: Completed
    @Published var selectedFilter: Int = 0

    private let dbManager = TodoDatabaseManager.shared
    private var listenerRegistration: ListenerRegistration?

    /// Filtered items based on the active tab
    var filteredItems: [TodoItem] {
        switch selectedFilter {
        case 1:
            return todoList.filter { !$0.isCompleted }
        case 2:
            return todoList.filter { $0.isCompleted }
        default:
            return todoList
        }
    }

    /// Subscribes to real-time task updates for the current user
    func startListening(userId: String) {
        stopListening()
        isLoading = true
        statusError = nil

        listenerRegistration = dbManager.subscribeToUserTodos(userId: userId) { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                self.isLoading = false
                switch result {
                case .success(let items):
                    self.todoList = items
                case .failure(let error):
                    self.statusError = error.localizedDescription
                }
            }
        }
    }

    /// Stops Firestore listener
    func stopListening() {
        listenerRegistration?.remove()
        listenerRegistration = nil
        todoList = []
    }

    /// Refresh tasks manually (pull-to-refresh)
    func refreshTasks(userId: String) async {
        isLoading = true
        statusError = nil
        do {
            self.todoList = try await dbManager.fetchUserTodos(userId: userId)
        } catch {
            self.statusError = error.localizedDescription
        }
        isLoading = false
    }

    /// Add new task
    func addTask(
        title: String,
        description: String,
        priority: String,
        userId: String
    ) async -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            statusError = "Title cannot be empty."
            return false
        }

        isLoading = true
        statusError = nil

        do {
            try await dbManager.createTodo(
                title: cleanTitle,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                priority: priority,
                userId: userId
            )
            isLoading = false
            return true
        } catch {
            statusError = error.localizedDescription
            isLoading = false
            return false
        }
    }

    /// Edit existing task
    func editTask(
        id: String,
        title: String,
        description: String,
        priority: String
    ) async -> Bool {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            statusError = "Title cannot be empty."
            return false
        }

        isLoading = true
        statusError = nil

        do {
            try await dbManager.updateTodo(
                id: id,
                title: cleanTitle,
                description: description.trimmingCharacters(in: .whitespacesAndNewlines),
                priority: priority
            )
            isLoading = false
            return true
        } catch {
            statusError = error.localizedDescription
            isLoading = false
            return false
        }
    }

    /// Toggle task completed status
    func toggleCompletion(for item: TodoItem) async {
        guard let id = item.id else { return }
        let newStatus = !item.isCompleted

        // Instant optimistic update
        if let idx = todoList.firstIndex(where: { $0.id == id }) {
            todoList[idx].isCompleted = newStatus
        }

        do {
            try await dbManager.setTodoCompletion(id: id, isCompleted: newStatus)
        } catch {
            // Revert on error
            if let idx = todoList.firstIndex(where: { $0.id == id }) {
                todoList[idx].isCompleted = !newStatus
            }
            statusError = error.localizedDescription
        }
    }

    /// Delete task by ID
    func deleteTask(id: String) async {
        do {
            try await dbManager.removeTodo(id: id)
        } catch {
            statusError = error.localizedDescription
        }
    }

    func clearError() {
        statusError = nil
    }
}

