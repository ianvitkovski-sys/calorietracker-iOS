import Foundation
import SwiftData
import Combine

@MainActor
final class FoodSearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var searchResults: [FoodDatabaseEntry] = []
    @Published var recentSearches: [String] = []
    @Published var isSearching = false
    @Published var errorMessage: String?

    weak var container: AppContainer?
    private var searchTask: Task<Void, Never>?
    private let maxRecentSearches = 10

    init(container: AppContainer) {
        self.container = container
        loadRecentSearches()
    }

    private func loadRecentSearches() {
        recentSearches = UserDefaults.standard.stringArray(forKey: "recentFoodSearches") ?? []
    }

    private func saveRecentSearches() {
        UserDefaults.standard.set(recentSearches, forKey: "recentFoodSearches")
    }

    func search(query: String) {
        self.query = query
        searchTask?.cancel()

        guard !query.isEmpty else {
            searchResults = []
            return
        }

        isSearching = true

        searchTask = Task {
            try? await Task.sleep(nanoseconds: 300_000_000)

            if Task.isCancelled { return }

            do {
                let results = try await DataManager.shared.searchFoodEntries(query: query)
                await MainActor.run {
                    searchResults = results
                    isSearching = false
                }

                if !recentSearches.contains(query.lowercased()) {
                    recentSearches.insert(query.lowercased(), at: 0)
                    if recentSearches.count > maxRecentSearches {
                        recentSearches.removeLast()
                    }
                    saveRecentSearches()
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    isSearching = false
                }
            }
        }
    }

    func clearSearch() {
        query = ""
        searchResults = []
        searchTask?.cancel()
    }

    func removeRecentSearch(_ search: String) {
        recentSearches.removeAll { $0 == search }
        saveRecentSearches()
    }

    func clearRecentSearches() {
        recentSearches.removeAll()
        saveRecentSearches()
    }
}
