//
//  TripsTableViewController.swift
//  Trip-Planner
//
//  Created by Erick Sanchez on 2/18/18.
//  Copyright © 2018 LinnierGames. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TripsTableViewController: UITableViewController {
    
    private var viewModel = TripsViewModel()
    
//    private var bag = DisposeBag()

    // MARK: - RETURN VALUES
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return false
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.arrayOfTrips().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        let trip = viewModel.arrayOfTrips()[indexPath.row]
        cell.textLabel?.text = trip.title
        
        return cell
    }
    
    // MARK: - VOID METHODS
    
    // MARK: - IBACTIONS
    
    @IBOutlet weak var buttonAdd: UIBarButtonItem!
    @IBAction func pressAddTrip(_ sender: Any) {
        let alertTrip = UIAlertController(title: "Add a Trip", message: "enter the title of your new trip", preferredStyle: .alert)
        alertTrip.addTextField()
        alertTrip.addAction(UIAlertAction(title: "Discard", style: .destructive))
        alertTrip.addAction(UIAlertAction(title: "Add", style: .default, handler: { [unowned self] (action) in
            let newTrip = TPTrip(title: alertTrip.textFields?[0].text ?? "Untitled")
            self.viewModel.add(a: newTrip, complition: { (result) in
                switch result {
                case .success:
                    self.tableView.reloadData()
                case .failure(let error):
                    let alertError = UIAlertController(title: "Add a Trip", message: "unexpected error: \(error.localizedDescription)", preferredStyle: .alert)
                    alertError.addAction(UIAlertAction(title: "Dismiss", style: .default))
                    self.present(alertError, animated: true)
                }
            })
        }))
        self.present(alertTrip, animated: true)
    }
    
    // MARK: - LIFE CYCLE
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
//        viewModel = TripsViewModel()
//
//
//        //Register addButton tap to append a new "Item" to the dataSource on each tap -> onNext
//        buttonAdd.rx.tap.asDriver().drive(onNext: { [unowned self] _ in
//            self.viewModel.privateDataSource.value.append("Item")
//        })
//            .disposed(by: bag)
//        tableView.dataSource = nil
//        tableView.delegate = nil
//        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
//        viewModel.dataSource.bind(to: tableView.rx.items(cellIdentifier: "cell", cellType: UITableViewCell.self)) { index, trip, cell in
//            cell.textLabel?.text = trip
//        }.disposed(by: bag)
    }

}
