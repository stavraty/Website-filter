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
        
    override func viewDidLoad() {
        super.viewDidLoad()

        setupViews()
        setupWebView()
        setupConstraints()
        setupActions()
        
        urlTextField.delegate = self

        if let url = URL(string: "https://www.google.com") {
            webView.load(URLRequest(url: url))
        }
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

    private func setupWebView() {
        webView.navigationDelegate = self
    }

    private func setupConstraints() {
        // Constraints
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
        urlTextField.addTarget(self, action: #selector(loadURL), for: .editingDidEnd) // змінено з .editingDidEndOnExit на .editingDidEnd
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
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 1.0
        textField.layer.borderColor = UIColor.systemBlue.cgColor
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.layer.borderWidth = 0.0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // виключити редагування текстового поля
        loadURL() // завантажити URL
        return true
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            for filter in filters {
                if url.absoluteString.contains(filter) {
                    let alert = UIAlertController(title: "Blocked", message: "This page has been blocked by a filter.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                    decisionHandler(.cancel)
                    return
                }
            }
        }
        decisionHandler(.allow)
    }

    // Action methods
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
                        let alert = UIAlertController(title: "Error", message: "Filter must have at least 2 characters and must not contain spaces.", preferredStyle: .alert)
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

    @objc private func loadURL() {
        if let urlText = urlTextField.text, let url = URL(string: urlText) {
            for filter in filters {
                if url.absoluteString.contains(filter) {
                    let alert = UIAlertController(title: "Blocked", message: "This page has been blocked by a filter.", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(okAction)
                    present(alert, animated: true, completion: nil)
                    return
                }
            }
            webView.load(URLRequest(url: url))
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
        case .failure(let error):
            var errorMessage: String
            switch error {
            case URLFilterError.invalidURL:
                errorMessage = "Please enter a valid URL."
            case URLFilterError.blockedURL:
                errorMessage = "This page has been blocked by a filter."
            case URLFilterError.invalidFilter:
                errorMessage = "Filter must have at least 2 characters and must not contain spaces."
            }
            let alert = UIAlertController(title: "Error", message: errorMessage, preferredStyle: .alert)
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            present(alert, animated: true, completion: nil)
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filters.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "filterCell", for: indexPath)
        cell.textLabel?.text = filters[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            filters.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        }
    }
}

extension BrowserViewController: FilterViewControllerDelegate {
    func filterViewController(_ controller: FilterViewController, didUpdateFilters filters: [String]) {
        self.filters = filters
    }
}
