//
//  ContentView.swift
//
//  Created by brian on 9/29/24.
//

import SwiftUI
import Combine

struct Item: Codable, Identifiable {
    let id: Int
    let listId: Int
    let name: String?
}

import Foundation
import CryptoKit

class ItemListViewModel: ObservableObject {
    @Published var characters: [Character] = []
    @Published var searchText = ""
    
    private let baseURL = "https://gateway.marvel.com/v1/public/characters"
    private let apiKey = ""
    private let privateKey = ""
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        $searchText
            .debounce(for: .milliseconds(300), scheduler: RunLoop.main)
            .filter { $0.count >= 2 }
            .sink { [weak self] in self?.fetchCharacters(startingWith: $0) }
            .store(in: &cancellables)
    }
    
    var filteredCharacters: [Character] {
        characters
    }
    
    func fetchCharacters(startingWith prefix: String) {
        let timestamp = String(Date().timeIntervalSince1970)
        let hash = MD5(string: timestamp + privateKey + apiKey)
        
        guard var urlComponents = URLComponents(string: baseURL) else { return }
        urlComponents.queryItems = [
            URLQueryItem(name: "apikey", value: apiKey),
            URLQueryItem(name: "ts", value: timestamp),
            URLQueryItem(name: "hash", value: hash),
            URLQueryItem(name: "nameStartsWith", value: prefix)
        ]
        
        guard let url = urlComponents.url else { return }
        
        // Print the full URL
        print("Fetching characters from URL: \(url)")
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error fetching data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decodedResponse = try JSONDecoder().decode(MarvelResponse.self, from: data)
                DispatchQueue.main.async {
                    self?.characters = decodedResponse.data.results
                }
            } catch {
                print("Error decoding JSON: \(error)")
            }
        }.resume()
    }
    
    private func MD5(string: String) -> String {
        let digest = Insecure.MD5.hash(data: string.data(using: .utf8) ?? Data())
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}

struct MarvelResponse: Codable {
    let data: CharacterDataContainer
}

struct CharacterDataContainer: Codable {
    let results: [Character]
}

struct Character: Codable, Identifiable {
    let id: Int
    let name: String
    let description: String
    let thumbnail: ImageInfo
}

struct ImageInfo: Codable {
    let path: String
    let fileExtension: String
    
    enum CodingKeys: String, CodingKey {
        case path
        case fileExtension = "extension"
    }
}

struct CharacterDetailView: View {
    let character: Character
    @ObservedObject var vungleManager: VungleManager
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                let imageUrl = "\(character.thumbnail.path).\(character.thumbnail.fileExtension)"
                    .replacingOccurrences(of: "http://", with: "https://")
                
                AsyncImage(url: URL(string: imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                    case .failure(let error):
                        Text("Failed to load image: \(error.localizedDescription)")
                    @unknown default:
                        EmptyView()
                    }
                }
                .frame(height: 300)
                
                Text(character.name)
                    .font(.title)
                    .fontWeight(.bold)
                
                if !character.description.isEmpty {
                    Text(character.description)
                        .font(.body)
                } else {
                    Text("No description available.")
                        .font(.body)
                        .italic()
                }
                
                Spacer()
            }
            .padding()
        }
        .navigationTitle(character.name)
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            showInterstitialAd()
        }
    }
    
    private func showInterstitialAd() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            print("Unable to find root view controller")
            return
        }
        
        vungleManager.showInterstitialAd(from: rootViewController)
    }
}


struct VungleNativeAdWrapper: UIViewControllerRepresentable {
    @ObservedObject var vungleManager: VungleManager

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        let nativeAdView = VungleNativeAdView(frame: .zero)
        viewController.view.addSubview(nativeAdView)
        
        nativeAdView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nativeAdView.topAnchor.constraint(equalTo: viewController.view.topAnchor),
            nativeAdView.leadingAnchor.constraint(equalTo: viewController.view.leadingAnchor),
            nativeAdView.trailingAnchor.constraint(equalTo: viewController.view.trailingAnchor),
            nativeAdView.bottomAnchor.constraint(equalTo: viewController.view.bottomAnchor)
        ])
        
        if let nativeAd = vungleManager.nativeAd {
            nativeAdView.configure(with: nativeAd, viewController: viewController)
        }
        
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Update if needed
    }
}

struct ContentView: View {
    @EnvironmentObject private var vungleManager: VungleManager
    @StateObject private var viewModel = ItemListViewModel()
    @State private var searchText = ""
    @Environment(\.horizontalSizeClass) var horizontalSizeClass

    var body: some View {
        NavigationStack {
            List {
                // Fixed search area
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                        TextField("Search characters", text: $viewModel.searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    .padding()
                    .background(Color(.systemBackground))
                    
                    Divider()
                        .background(Color.gray)
                }
                
                // Scrollable content area
                if viewModel.searchText.count < 2 {
                    Text("Type at least 2 characters to search")
                        .foregroundColor(.gray)
                        .padding()
                } else if viewModel.characters.isEmpty {
                    Text("No characters found")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    ForEach(Array(viewModel.filteredCharacters.enumerated()), id: \.element.id) { index, character in
                        NavigationLink(destination: CharacterDetailView(character: character, vungleManager: vungleManager)) {
                            HStack {
                                Text(character.name)
                                Spacer()
                                Text("ID: \(character.id)")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                        }
                        Divider()
                        
                        // Banner ad after the 3rd item
                        if index == 2 && vungleManager.isBannerAdReady {
                            BannerAdView(vungleManager: vungleManager)
                                .frame(height: 50)
                        }
                        
                        // Rewarded ad button at the 6th item
                        if index == 5 && vungleManager.isRewardedAdReady {
                            Button("Watch Rewarded Ad") {
                                vungleManager.showRewardedAd()
                            }
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        }

                        // Insert native ad after every 8 items (changed from 5 to 8 to match your code)
                        if (index + 1) % 8 == 0 && vungleManager.isNativeAdReady {
                            VungleNativeAdWrapper(vungleManager: vungleManager)
                                .frame(minHeight: 350, maxHeight: 500)
                                .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Marvel Characters")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ItemDetailView: View {
    let item: Item
    
    var body: some View {
        VStack {
            Text("Item Details")
                .font(.title)
                .padding()
            
            VStack(alignment: .leading, spacing: 10) {
                Text("ID: \(item.id)")
                Text("List ID: \(item.listId)")
                Text("Name: \(item.name ?? "N/A")")
            }
        }
        .navigationTitle("Item \(item.id)")
    }
}

// Preview
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(VungleManager.shared)  // Add this line for previews
    }
}
