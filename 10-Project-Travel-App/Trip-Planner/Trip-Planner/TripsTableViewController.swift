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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let identifier = segue.identifier {
            switch identifier {
            case "show editor":
                break
            case "show detailed":
                break
            default: break
            }
        }
    }
    
    // MARK: - IBACTIONS
    
    // MARK: - LIFE CYCLE
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        viewModel.reloadTrips { (result) in
            self.tableView.reloadData()
        }
    }
    
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
