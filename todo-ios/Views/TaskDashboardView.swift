import SwiftUI
import FirebaseAuth

// MARK: - Lab Assignment: Task Dashboard Screen
// Features: List of tasks, filter by (All / Pending / Done), swipe to delete, completion toggle, Add & Edit sheets.

struct TaskDashboardView: View {
    @EnvironmentObject var authVM: AuthViewModel
    @StateObject private var todoVM = TodoListViewModel()

    @State private var showingAddSheet = false
    @State private var editingItem: TodoItem? = nil

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Segmented Filter Bar: All | Pending | Completed
                Picker("Filter", selection: $todoVM.selectedFilter) {
                    Text("All (\(todoVM.todoList.count))").tag(0)
                    Text("Pending (\(todoVM.todoList.filter { !$0.isCompleted }.count))").tag(1)
                    Text("Done (\(todoVM.todoList.filter { $0.isCompleted }.count))").tag(2)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                .padding(.vertical, 8)

                ZStack {
                    if todoVM.filteredItems.isEmpty && !todoVM.isLoading {
                        // Empty State View
                        VStack(spacing: 14) {
                            Image(systemName: "tray")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)

                            Text("No Tasks Found")
                                .font(.title3)
                                .fontWeight(.semibold)

                            Text("Tap the '+' button in the top right to create your first task.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                    } else {
                        // Task List
                        List {
                            ForEach(todoVM.filteredItems) { item in
                                TaskCardRow(
                                    item: item,
                                    onToggle: {
                                        Task {
                                            await todoVM.toggleCompletion(for: item)
                                        }
                                    },
                                    onEdit: {
                                        editingItem = item
                                    }
                                )
                                .listRowSeparator(.hidden)
                                .listRowInsets(EdgeInsets(top: 6, leading: 16, bottom: 6, trailing: 16))
                                .listRowBackground(Color.clear)
                            }
                            .onDelete(perform: removeItems)
                        }
                        .listStyle(.plain)
                        .refreshable {
                            if let uid = authVM.currentUserId {
                                await todoVM.refreshTasks(userId: uid)
                            }
                        }
                    }

                    // Loading Spinner for initial fetch
                    if todoVM.isLoading && todoVM.todoList.isEmpty {
                        ProgressView("Syncing with Firestore...")
                    }
                }
            }
            .navigationTitle("My Tasks")
            .toolbar {
                // Leading: Sign Out
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        todoVM.stopListening()
                        authVM.signOut()
                    }) {
                        HStack(spacing: 4) {
                            Image(systemName: "arrow.backward.circle")
                            Text("Logout")
                        }
                        .foregroundColor(.red)
                        .font(.footnote)
                    }
                }

                // Trailing: Add Task
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        showingAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.purple)
                    }
                }
            }
            // Add Task Sheet
            .sheet(isPresented: $showingAddSheet) {
                if let uid = authVM.currentUserId {
                    AddEditTaskSheet(
                        todoVM: todoVM,
                        existingItem: nil,
                        userId: uid
                    )
                }
            }
            // Edit Task Sheet
            .sheet(item: $editingItem) { item in
                if let uid = authVM.currentUserId {
                    AddEditTaskSheet(
                        todoVM: todoVM,
                        existingItem: item,
                        userId: uid
                    )
                }
            }
            .onAppear {
                if let uid = authVM.currentUserId {
                    todoVM.startListening(userId: uid)
                }
            }
            .onDisappear {
                todoVM.stopListening()
            }
            .alert("Error", isPresented: Binding(
                get: { todoVM.statusError != nil },
                set: { if !$0 { todoVM.clearError() } }
            )) {
                Button("OK", role: .cancel) {
                    todoVM.clearError()
                }
            } message: {
                Text(todoVM.statusError ?? "Unknown error occurred.")
            }
        }
    }

    private func removeItems(at offsets: IndexSet) {
        for idx in offsets {
            let item = todoVM.filteredItems[idx]
            if let id = item.id {
                Task {
                    await todoVM.deleteTask(id: id)
                }
            }
        }
    }
}

#Preview {
    TaskDashboardView()
        .environmentObject(AuthViewModel())
}

