//
//  SearchTableViewController.swift
//  BmScanner
//
//  Created by Aung Ko Min on 26/4/21.
//

import UIKit

protocol SearchTableViewControllerDelegate: class {
    func controller(_ controller: SearchTableViewController, didSelect note: Note)
}
class SearchTableViewController: UITableViewController {
    
    weak var delegate: SearchTableViewControllerDelegate?
    
    private let searchController = UISearchController(searchResultsController: nil)
    private var notes = [Note]()
    private let context = PersistenceController.shared.container.viewContext
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search Notes"
        searchController.searchBar.delegate = self
        navigationItem.searchController = searchController
        
        tableView.register(SearchTableViewCell.self, forCellReuseIdentifier: SearchTableViewCell.reuseIdentifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchController.isActive = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        Async.main {
            self.searchController.searchBar.becomeFirstResponder()
        }
    }
}

extension SearchTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        
    }
}

extension SearchTableViewController: UISearchBarDelegate {
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        navigationController?.dismiss(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        SoundManager.playSound(tone: .Tock)
        let request = Note.fetchRequest(for: searchText)
        do {
            notes = try context.fetch(request)
            tableView.reloadData()
        } catch {
            Log(error)
        }
    }
}



extension SearchTableViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return notes.isEmpty ? 0 : 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notes.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchTableViewCell.reuseIdentifier, for: indexPath) as? SearchTableViewCell else {
            fatalError()
        }
        let note = notes[indexPath.row]
        cell.configure(note)
        
        return cell
    }
    
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let note = notes[indexPath.row]
        delegate?.controller(self, didSelect: note)
    }
    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return notes.isEmpty ? nil : "Results"
    }
    
    override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return notes.isEmpty ? nil : "\(notes.count) Items"
    }
}
