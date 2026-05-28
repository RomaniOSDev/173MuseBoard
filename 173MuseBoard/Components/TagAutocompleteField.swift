import SwiftUI

struct TagAutocompleteField: View {
    @Binding var tagsString: String
    let suggestions: [String]

    @State private var showSuggestions = false

    private var currentToken: String {
        let parts = tagsString.split(separator: ",", omittingEmptySubsequences: false)
        return parts.last.map { String($0).trimmingCharacters(in: .whitespaces) } ?? ""
    }

    private var filteredSuggestions: [String] {
        let token = currentToken.lowercased()
        guard !token.isEmpty else { return [] }
        return suggestions
            .filter { $0.lowercased().contains(token) && $0.lowercased() != token }
            .prefix(6)
            .map { $0 }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            TextField("Tags separated by commas", text: $tagsString)
                .foregroundColor(.museDeep)
                .onChange(of: tagsString) { _ in
                    showSuggestions = !filteredSuggestions.isEmpty
                }

            if showSuggestions, !filteredSuggestions.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(filteredSuggestions, id: \.self) { tag in
                            Button {
                                applySuggestion(tag)
                            } label: {
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(Color.museAccent.opacity(0.12))
                                    .foregroundColor(.museAccent)
                                    .cornerRadius(12)
                            }
                        }
                    }
                }
            }
        }
    }

    private func applySuggestion(_ tag: String) {
        var parts = tagsString.split(separator: ",", omittingEmptySubsequences: false).map(String.init)
        if parts.isEmpty {
            tagsString = tag
        } else {
            parts[parts.count - 1] = " \(tag)"
            tagsString = parts.joined(separator: ",")
        }
        showSuggestions = false
    }
}
