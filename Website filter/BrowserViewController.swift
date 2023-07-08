//
//  ViewController.swift
//  Website filter
//
//  Created by AS on 06.07.2023.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {

    private var webView: WKWebView!
    private var urlTextField: UITextField!
    private var backButton: UIButton!
    private var forwardButton: UIButton!
    private var filterButton: UIButton!
    private var viewFilterButton: UIButton!
    private var filters: [String] = []
    private var filtersTableView: UITableView!
    private let reachability = try! Reachability()
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupDelegates()
        setupConstraints()
        setupActions()
        setupReachability()
        setupInitialURL()
    }
    
    private func setupViews() {
        urlTextField = createTextField(withPlaceholder: "Enter URL")
        setupTextFieldAppearance(textField: urlTextField, isEditable: true)

        backButton = createButton(withTitle: "Back")
        setupButtonAppearance(button: backButton)

        forwardButton = createButton(withTitle: "Forward")
        setupButtonAppearance(button: forwardButton)

        filterButton = createButton(withTitle: "Add Filter")
        setupButtonAppearance(button: filterButton)

        viewFilterButton = createButton(withTitle: "View Filters")
        setupButtonAppearance(button: viewFilterButton)

        webView = createWebView()
        view.addSubview(webView)
    }

    private func setupDelegates() {
        webView.navigationDelegate = self
        urlTextField.delegate = self
    }

    private func setupConstraints() {
        NSLayoutConstraint.activate([
            urlTextField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            urlTextField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            urlTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),

            backButton.topAnchor.constraint(equalTo: urlTextField.bottomAnchor, constant: 10),
            backButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            backButton.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 0.25),

            forwardButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            forwardButton.leadingAnchor.constraint(equalTo: backButton.trailingAnchor),
            forwardButton.widthAnchor.constraint(equalTo: backButton.widthAnchor),

            filterButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            filterButton.leadingAnchor.constraint(equalTo: forwardButton.trailingAnchor),
            filterButton.widthAnchor.constraint(equalTo: backButton.widthAnchor),

            viewFilterButton.topAnchor.constraint(equalTo: backButton.topAnchor),
            viewFilterButton.leadingAnchor.constraint(equalTo: filterButton.trailingAnchor),
            viewFilterButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),

            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.topAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 10),
            webView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        forwardButton.addTarget(self, action: #selector(goForward), for: .touchUpInside)
        filterButton.addTarget(self, action: #selector(addFilter), for: .touchUpInside)
        viewFilterButton.addTarget(self, action: #selector(viewFilters), for: .touchUpInside)
        urlTextField.addTarget(self, action: #selector(openUrl), for: .editingDidEnd)
    }
    
    private func setupReachability() {
        reachability.whenUnreachable = { _ in
            self.showErrorAlert(for: .noInternetConnection)
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
    }

    private func setupInitialURL() {
        if let url = URL(string: "https://www.google.com") {
            webView.load(URLRequest(url: url))
        }
    }

    private func createTextField(withPlaceholder placeholder: String) -> UITextField {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = placeholder
        textField.borderStyle = .roundedRect
        textField.returnKeyType = .search
        return textField
    }
    
    private func setupTextFieldAppearance(textField: UITextField, isEditable: Bool) {
        textField.isUserInteractionEnabled = isEditable
        textField.delegate = self
        textField.layer.cornerRadius = 5
        view.addSubview(textField)
    }

    private func createButton(withTitle title: String) -> UIButton {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle(title, for: .normal)
        return button
    }

    private func setupButtonAppearance(button: UIButton) {
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 1
        view.addSubview(button)
    }

    private func createWebView() -> WKWebView {
        let webView = WKWebView()
        webView.translatesAutoresizingMaskIntoConstraints = false
        return webView
    }
    
    private func showErrorAlert(for error: AppError) {
        let alert = UIAlertController(title: error.title, message: error.message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
    
    private func checkConnection() {
            reachability.whenUnreachable = { _ in
                self.showErrorAlert(for: .noInternetConnection)
            }

            do {
                try reachability.startNotifier()
            } catch {
                print("Unable to start notifier")
            }
        }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        openUrl()
        return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            for filter in filters {
                if url.absoluteString.contains(filter) {
                    showErrorAlert(for: .blockedURL)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }

    @objc private func goBack() {
        if webView.canGoBack {
            webView.goBack()
        }
    }

    @objc private func goForward() {
        if webView.canGoForward {
            webView.goForward()
        }
    }

    @objc private func addFilter() {
        let alert = UIAlertController(title: "Add Filter", message: nil, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Filter text"
        }
        let addAction = UIAlertAction(title: "Add", style: .default) { _ in
            if let text = alert.textFields?.first?.text, !text.isEmpty {
                let urlManager = URLFilterManager(filters: [text])
                if case .failure(let error) = urlManager.checkUrl("https://www.google.com") {
                    switch error {
                    case .invalidFilter:
                        let alert = UIAlertController(title: "Error", message: "Filter must have at least 2 characters and must not contain spaces", preferredStyle: .alert)
                        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                        alert.addAction(okAction)
                        self.present(alert, animated: true, completion: nil)
                    default:
                        break
                    }
                } else {
                    self.filters.append(text)
                }
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    @objc private func viewFilters() {
        performSegue(withIdentifier: "viewFiltersSegue", sender: nil)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "viewFiltersSegue", let filterVC = segue.destination as? FilterViewController {
            filterVC.filters = self.filters
            filterVC.delegate = self
        }
    }

    @objc func openUrl() {
        guard let text = urlTextField?.text else {
            return
        }

        let urlManager = URLFilterManager(filters: self.filters)
        switch urlManager.checkUrl(text) {
        case .success(let url):
            let request = URLRequest(url: url)
            webView.load(request)
        case .failure(let appError):
            showErrorAlert(for: appError)
        }
    }
}

extension BrowserViewController: FilterViewControllerDelegate {
    func filterViewController(_ controller: FilterViewController, didUpdateFilters filters: [String]) {
        self.filters = filters
    }
}
