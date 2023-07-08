//
//  AppError.swift
//  Website filter
//
//  Created by AS on 08.07.2023.
//

import Foundation

enum AppError: Error {
    case invalidURL
    case blockedURL
    case invalidFilter
    case webViewError(title: String, message: String)
    case noInternetConnection

    var title: String {
        switch self {
        case .webViewError(let title, _):
            return title
        default:
            return "Error"
        }
    }

    var message: String {
        switch self {
        case .webViewError(_, let message):
            return message
        case .invalidURL:
            return "Please enter a valid URL"
        case .blockedURL:
            return "This page has been blocked by a filter"
        case .invalidFilter:
            return "Filter must have at least 2 characters and must not contain spaces"
        case .noInternetConnection:
            return "No internet connection. Please check your connection and try again"
        }
    }
}
