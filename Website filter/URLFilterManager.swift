//
//  URLFilterManager.swift
//  Website filter
//
//  Created by AS on 07.07.2023.
//

import UIKit

enum URLFilterError: Error {
    case invalidURL
    case blockedURL
    case invalidFilter
}

class URLFilterManager {

    var filters: [String]
    
    init(filters: [String]) {
        self.filters = filters
    }

    func checkUrl(_ urlString: String) -> Result<URL, URLFilterError> {
        var completeUrlString = urlString
        if !completeUrlString.hasPrefix("http://") && !completeUrlString.hasPrefix("https://") {
            completeUrlString = "https://" + completeUrlString
        }

        guard let url = URL(string: completeUrlString) else {
            return .failure(.invalidURL)
        }

        for filter in filters {
            guard filter.count >= 2, !filter.contains(" ") else {
                return .failure(.invalidFilter)
            }

            if url.absoluteString.contains(filter) {
                return .failure(.blockedURL)
            }
        }
        
        return .success(url)
    }

}
