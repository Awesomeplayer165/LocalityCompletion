//
//  ViewController.swift
//  LocalityCompletion
//
//  Created by Jacob Trentini on 8/3/21.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController {
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var tableView: UITableView!
    
    var searchCompleter = MKLocalSearchCompleter()
    var searchResults = [MKLocalSearchCompletion]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        searchCompleter.delegate = self
        searchBar.delegate = self
        mapView.isHidden = false
    }
}

extension ViewController:UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard !searchBar.text!.isEmpty else {
            return 1
        }
        return searchResults.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard !searchBar.text!.isEmpty else {
            print("empty")
            let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
            cell.textLabel?.text = "Start typing for Local Search Results..."
            return cell
        }
        
        let searchResult = searchResults[indexPath.row]
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: nil)
        cell.textLabel?.text = searchResult.title
        cell.detailTextLabel?.text = searchResult.subtitle
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard !searchBar.text!.isEmpty else {
            return
        }
        
        let completion = searchResults[indexPath.row]
        let searchRequest = MKLocalSearch.Request(completion: completion)
        let search = MKLocalSearch(request: searchRequest)
        search.start { (response, error) in
            let coordinate = response?.mapItems[0].placemark.coordinate
            print(String(describing: coordinate))
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate!
            annotation.title = response?.mapItems[0].name
            annotation.subtitle = response?.mapItems[0].description
            DispatchQueue.main.async { [self] in
                view.endEditing(true)
                mapView.isHidden = false
                mapView.addAnnotation(annotation)
                let region = MKCoordinateRegion.init(center: coordinate!, latitudinalMeters: 5000, longitudinalMeters: 5000)
                mapView.setRegion(region, animated: true)
            }
        }
    }
}

extension ViewController:MKLocalSearchCompleterDelegate {
    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        searchResults = completer.results
        tableView.reloadData()
        print("Results = \(completer.results)")
    }
    
    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        // handle error
        print("Error with \(error)")
    }
}

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCompleter.queryFragment = searchText
        print("New text = \(searchText)")
    }
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        mapView.isHidden = true
        return true
    }
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        mapView.isHidden = false
        return true
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
        mapView.isHidden = false
        tableView.reloadData()
    }
}
