//
//  ViewController.swift
//  StoreSearch
//
//  Created by Gleb on 29.10.17.
//  Copyright © 2017 Gleb. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!

    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NothingFoundCell"
        static let loadingCell = "LoadingCell"
    }

    fileprivate var searchResults: [SearchResult] = []
    fileprivate var hasSearched = false
    fileprivate var isLoading = false

    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.becomeFirstResponder()
        tableView.contentInset = UIEdgeInsets(top: 64, left: 0, bottom: 0, right: 0)
        tableView.rowHeight = 80
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)

        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)

        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.register(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    fileprivate func iTunesURL(searchText: String) -> URL {
        let escapedSearchText = searchText.addingPercentEncoding(
            withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", escapedSearchText)
        let url = URL(string: urlString)
        return url!
    }

    fileprivate func performStoreRequest(with url: URL) -> String? {
        do {
            return try String(contentsOf: url, encoding: .utf8)
        } catch {
            print("Download Error: \(error)")
            return nil
        }
    }

    fileprivate func parse(json: String) -> [String: Any]? {
        guard let data = json.data(using: .utf8, allowLossyConversion: false)
            else { return nil }

        do {
            return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
        } catch {
            print("JSON Error: \(error)")
            return nil
        }
    }

    fileprivate func parse(dictionary: [String: Any]) -> [SearchResult] {
        guard let array = dictionary["results"] as? [Any] else {
            print("Expected 'results' array")
            return []
        }

        var searchResults = [SearchResult]()
        for resultDict in array {
            if let resultDict = resultDict as? [String: Any] {
                var searchResult: SearchResult?
                if let wrapperType = resultDict["wrapperType"] as? String {
                    switch wrapperType {
                    case "track":
                        searchResult = parse(track: resultDict)
                    case "audiobook":
                        searchResult = parse(audiobook: resultDict)
                    case "software":
                        searchResult = parse(software: resultDict)
                    default:
                        break
                    }
                } else if let kind = resultDict["kind"] as? String, kind == "ebook" {
                    searchResult = parse(ebook: resultDict)
                }
                if let result = searchResult {
                    searchResults.append(result)
                }
            }
        }
        return searchResults
    }

    fileprivate func parse(track dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()

        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String

        if let price = dictionary["trackPrice"] as? Double {
            searchResult.price = price
        }

        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }

        return searchResult
    }

    fileprivate func parse(audiobook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["collectionName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["collectionViewUrl"] as! String
        searchResult.kind = "audiobook"
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["collectionPrice"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }

    fileprivate func parse(software dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genre = dictionary["primaryGenreName"] as? String {
            searchResult.genre = genre
        }
        return searchResult
    }

    fileprivate func parse(ebook dictionary: [String: Any]) -> SearchResult {
        let searchResult = SearchResult()
        searchResult.name = dictionary["trackName"] as! String
        searchResult.artistName = dictionary["artistName"] as! String
        searchResult.artworkSmallURL = dictionary["artworkUrl60"] as! String
        searchResult.artworkLargeURL = dictionary["artworkUrl100"] as! String
        searchResult.storeURL = dictionary["trackViewUrl"] as! String
        searchResult.kind = dictionary["kind"] as! String
        searchResult.currency = dictionary["currency"] as! String
        if let price = dictionary["price"] as? Double {
            searchResult.price = price
        }
        if let genres: Any = dictionary["genres"] {
            searchResult.genre = (genres as! [String]).joined(separator: ", ")
        }
        return searchResult
    }

    fileprivate func showNetworkError() {
        let alert = UIAlertController(
            title: "Whoops...",
            message:"There was an error reading from the iTunes Store. Please try again",
            preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(action)

        present(alert, animated: true, completion: nil)
    }

    fileprivate func kindForDisplay(_ kind: String) -> String {
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcase": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV Episode"
        default: return kind
        }
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !searchBar.text!.isEmpty {
            hasSearched = true
            searchBar.resignFirstResponder()

            isLoading = true
            tableView.reloadData()

            searchResults = []

            let url = iTunesURL(searchText: searchBar.text!)
            print("URL: '\(url)'")

            let queue = DispatchQueue.global()

            queue.async { [weak self] in
                if let jsonString = self?.performStoreRequest(with: url) {
                    if let jsonDictionary = self?.parse(json: jsonString) {
                        print("Dictionary \(jsonDictionary)")
                        self?.searchResults = self?.parse(dictionary: jsonDictionary) ?? []
                        self?.searchResults.sort(by: <)

                        DispatchQueue.main.async { [weak self] in
                            self?.isLoading = false
                            self?.tableView.reloadData()
                        }
                    }
                } else {
                    DispatchQueue.main.async { [weak self] in
                        self?.showNetworkError()
                    }
                }
            }
        }
    }
}

extension SearchViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isLoading || searchResults.isEmpty {
            return 1
        } else if !hasSearched {
            return 0
        } else {
            return searchResults.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.loadingCell,
                                                     for: indexPath)

            let spinner = tableView.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        }

        if searchResults.isEmpty {
            return tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.nothingFoundCell,
                                                 for: indexPath)
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableViewCellIdentifiers.searchResultCell,
                                                 for: indexPath) as! SearchResultCell

            let searchResult = searchResults[indexPath.row]
            if searchResult.artistName.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            } else {
                cell.artistNameLabel.text = String(format: "%@ (%@)",
                                                   searchResult.artistName, kindForDisplay(searchResult.kind))
            }
            cell.nameLabel.text = searchResult.name
            return cell
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return searchResults.isEmpty || isLoading ? nil : indexPath
    }
    
}

extension SearchViewController: UITableViewDelegate {
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
