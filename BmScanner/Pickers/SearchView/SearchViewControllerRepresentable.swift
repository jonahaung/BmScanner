//
//  SearchViewControllerRepresentable.swift
//  BmScanner
//
//  Created by Aung Ko Min on 26/4/21.
//

import SwiftUI

struct SearchViewControllerRepresentable: UIViewControllerRepresentable {
    
    var onSearch: (Note) -> Void
    
    typealias UIViewControllerType = UINavigationController
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SearchViewControllerRepresentable>) -> UIViewControllerType {
        let searchController = SearchTableViewController(style: .insetGrouped)
        searchController.delegate = context.coordinator
        return UIViewControllerType(rootViewController: searchController)
    }

    func updateUIViewController(_ uiViewController: UIViewControllerType, context: UIViewControllerRepresentableContext<SearchViewControllerRepresentable>) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    
    class Coordinator: NSObject, SearchTableViewControllerDelegate {
        
        private let parent: SearchViewControllerRepresentable
        
        init(_ parent: SearchViewControllerRepresentable) {
            self.parent = parent
        }
        
        func controller(_ controller: SearchTableViewController, didSelect note: Note) {
            controller.navigationController?.dismiss(animated: true, completion: {
                self.parent.onSearch(note)
            })
        }
    }
}
