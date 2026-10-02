import SwiftUI
import SwiftData

struct SearchResultsView: View {
    @ObservedObject var viewModel: FoodSearchViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                searchBar

                if viewModel.recentSearches.isEmpty && viewModel.query.isEmpty {
                    recentSearchesEmpty
                } else if isSearching {
                    ProgressView("Searching...")
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    resultsList
                }
            }
            .navigationTitle("Search Foods")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: clearSearch) {
                        Image(systemName: "xmark.circle.fill")
                    }
                    .disabled(viewModel.query.isEmpty)
                }
            }
        }
        .searchable(text: $viewModel.query, placement: .navigationDisplayInline)
        .onChange(of: viewModel.query) { _, newValue in
            viewModel.search(query: newValue)
        }
    }

    @ViewBuilder
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppTheme.secondaryTextColor)
            Text("Search foods...")
                .foregroundColor(AppTheme.secondaryTextColor)
        }
        .padding(.horizontal)
        .padding(.vertical, 10)
        .background(AppTheme.cardBackground)
        .cornerRadius(AppTheme.cornerRadius)
        .padding()
    }

    @ViewBuilder
    private var resultsList: some View {
        List(viewModel.searchResults) { entry in
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.subheadline)

                Text("\(Int(entry.caloriesPer100g)) kcal/100g · \(entry.category ?? "Uncategorized")")
                    .font(.caption)
                    .foregroundColor(AppTheme.secondaryTextColor)
            }
            .listRowSeparator(.hidden)
        }
        .listStyle(.plain)
    }

    @ViewBuilder
    private var recentSearchesEmpty: some View {
        VStack(spacing: 16) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.secondaryTextColor.opacity(0.5))

            Text("Search for foods")
                .font(.headline)
                .foregroundColor(AppTheme.secondaryTextColor)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var isSearching: Bool {
        viewModel.isSearching
    }

    private func clearSearch() {
        viewModel.clearSearch()
    }
}
