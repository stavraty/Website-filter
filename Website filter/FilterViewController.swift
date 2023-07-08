//
//  FilterViewController.swift
//  Website filter
//
//  Created by AS on 07.07.2023.
//

import UIKit

protocol FilterViewControllerDelegate: AnyObject {
    func filterViewController(_ controller: FilterViewController, didUpdateFilters filters: [String])
}

class FilterViewController: UIViewController {
    var filters: [String] = [] {
        didSet {
            updateBackgroundState()
        }
    }

    private var filtersTableView: UITableView!
    weak var delegate: FilterViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupTableView()
        setupConstraints()
        setupEmptyBackgroundView()
        updateBackgroundState()
    }
    
    private func setupTableView() {
        filtersTableView = UITableView()
        view.addSubview(filtersTableView)
        filtersTableView.delegate = self
        filtersTableView.dataSource = self
        filtersTableView.register(UITableViewCell.self, forCellReuseIdentifier: "filterCell")
    }

    private func setupConstraints() {
        filtersTableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            filtersTableView.topAnchor.constraint(equalTo: view.topAnchor),
            filtersTableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            filtersTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            filtersTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
    }
    
    private func setupEmptyBackgroundView() {
        let emptyLabel = UILabel()
        emptyLabel.text = "No filters added"
        emptyLabel.textAlignment = .center
        emptyLabel.textColor = .gray
        filtersTableView.backgroundView = emptyLabel
    }
    
    private func updateBackgroundState() {
        if let backgroundView = filtersTableView?.backgroundView {
            backgroundView.isHidden = !filters.isEmpty
        }
    }
}

extension FilterViewController: UITableViewDelegate, UITableViewDataSource {
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
            delegate?.filterViewController(self, didUpdateFilters: filters)
        }
    }
}
