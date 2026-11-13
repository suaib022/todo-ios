import SwiftUI

// MARK: - Lab Assignment: Task Card Row Component
// Displays task title, description, priority badge, creation date, and completion toggle button.

struct TaskCardRow: View {
    let item: TodoItem
    let onToggle: () -> Void
    let onEdit: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 14) {
            // Completion Checkbox Button
            Button(action: onToggle) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(item.isCompleted ? .purple : .gray)
            }
            .buttonStyle(.plain)
            .padding(.top, 2)

            // Content: Title, Description, Priority & Date
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(item.title)
                        .font(.headline)
                        .strikethrough(item.isCompleted, color: .secondary)
                        .foregroundColor(item.isCompleted ? .secondary : .primary)

                    Spacer()

                    // Priority Badge
                    PriorityBadge(priority: item.priority)
                }

                if !item.description.isEmpty {
                    Text(item.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .lineLimit(2)
                }

                // Date Label
                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.caption2)
                    Text(item.createdAt.formatted(date: .abbreviated, time: .shortened))
                        .font(.caption2)
                }
                .foregroundColor(.secondary.opacity(0.8))
                .padding(.top, 2)
            }

            // Edit Action Button
            Button(action: onEdit) {
                Image(systemName: "square.and.pencil")
                    .font(.system(size: 16))
                    .foregroundColor(.indigo)
                    .padding(6)
            }
            .buttonStyle(.plain)
        }
        .padding(14)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.04), radius: 3, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            onEdit()
        }
    }
}

/// Helper view for Priority Tag Badge
struct PriorityBadge: View {
    let priority: String

    var color: Color {
        switch priority {
        case "High": return .red
        case "Medium": return .orange
        case "Low": return .green
        default: return .blue
        }
    }

    var body: some View {
        Text(priority)
            .font(.system(size: 10, weight: .bold))
            .padding(.horizontal, 8)
            .padding(.vertical, 3)
            .background(color.opacity(0.15))
            .foregroundColor(color)
            .clipShape(Capsule())
    }
}

