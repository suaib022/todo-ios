import SwiftUI

// MARK: - Lab Assignment: Add / Edit Task Modal Sheet
// Supports both adding a new task and editing an existing task in Cloud Firestore.

struct AddEditTaskSheet: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var todoVM: TodoListViewModel

    var existingItem: TodoItem?
    let userId: String

    // Form states
    @State private var title: String = ""
    @State private var description: String = ""
    @State private var priority: String = "Medium"
    @State private var isSaving: Bool = false
    @State private var validationError: String?

    var isEditMode: Bool {
        existingItem != nil
    }

    var body: some View {
        NavigationStack {
            Form {
                // Section 1: Title & Priority
                Section(header: Text("Task Overview")) {
                    TextField("Enter task title", text: $title)
                        .textInputAutocapitalization(.sentences)

                    Picker("Priority", selection: $priority) {
                        ForEach(TaskPriority.allCases) { p in
                            Text(p.rawValue).tag(p.rawValue)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                // Section 2: Detailed Description
                Section(header: Text("Description / Notes (Optional)")) {
                    ZStack(alignment: .topLeading) {
                        if description.isEmpty {
                            Text("Add details about this assignment or task...")
                                .foregroundColor(Color(UIColor.placeholderText))
                                .padding(.top, 8)
                                .padding(.leading, 4)
                        }
                        TextEditor(text: $description)
                            .frame(minHeight: 110)
                    }
                }

                // Error message banner
                if let err = validationError ?? todoVM.statusError {
                    Section {
                        Text(err)
                            .font(.footnote)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle(isEditMode ? "Edit Task" : "Create Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                // Cancel
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                // Save / Add
                ToolbarItem(placement: .confirmationAction) {
                    Button(isEditMode ? "Save" : "Add") {
                        handleSave()
                    }
                    .fontWeight(.bold)
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSaving)
                }
            }
            .onAppear {
                if let item = existingItem {
                    self.title = item.title
                    self.description = item.description
                    self.priority = item.priority
                }
            }
        }
    }

    private func handleSave() {
        let cleanTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !cleanTitle.isEmpty else {
            validationError = "Please enter a valid task title."
            return
        }

        isSaving = true
        validationError = nil

        Task {
            let success: Bool
            if let item = existingItem, let itemId = item.id {
                // Edit mode
                success = await todoVM.editTask(
                    id: itemId,
                    title: cleanTitle,
                    description: description,
                    priority: priority
                )
            } else {
                // Create mode
                success = await todoVM.addTask(
                    title: cleanTitle,
                    description: description,
                    priority: priority,
                    userId: userId
                )
            }

            isSaving = false

            if success {
                dismiss()
            }
        }
    }
}

#Preview {
    AddEditTaskSheet(
        todoVM: TodoListViewModel(),
        existingItem: nil,
        userId: "demoUser"
    )
}

