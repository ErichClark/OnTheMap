//
//  InformationPostingViewController.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/23/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import UIKit
import MapKit

class InformationPostingViewController: UIViewController {

    @IBOutlet weak var geoSearchTextField: UITextField!
    @IBOutlet weak var urlTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var debuggingTextField: UITextField!
    @IBOutlet weak var resultsTableView: UITableView!
    
    
    // Data model objects
    let locationManager = CLLocationManager()
    var mapClient: MapClient!
    var region: MKCoordinateRegion? = nil
    
    // Parameters to bundle into Segue for pin posting
    var resultForMapConfirmation: MKMapItem? = nil
    var urlToBundle: String? = nil
    
    var resultsFromSearch: [MKMapItem]? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the mapClient
        mapClient = MapClient.sharedInstance()
        self.geoSearchTextField.delegate = self as? UITextFieldDelegate
        urlTextField.text = MapClient.DummyUserData.MediaURLValue
    }
    
    @IBAction func returnPressed(_ sender: Any) {
        findLocation(self)
    }
    
    @IBAction func findLocation(_ sender: Any) {
        if geoSearchTextField.text == "" {
            displayTextOnUI("Please enter a location to search.")
        } else {
            
            performUIUpdatesOnMain {
                self.activityIndicator.startAnimating()
                self.displayTextOnUI("Searching for a location match...")
            }
            
            let queryText = geoSearchTextField.text
            let queryRegion = region ?? MapClient.sharedInstance().defaultRegion!
            
            mapClient.getResultsFromStringQuery(queryString: queryText!, region: queryRegion) { (success, returnedResults, errorString) in
                
                performUIUpdatesOnMain {
                    self.activityIndicator.stopAnimating()
                }
                
                performUIUpdatesOnMain {
                    if success! {
                        let successMessage = "** Success! Match(es) found."
                        print(successMessage)
                        self.resultsFromSearch = returnedResults
                        self.resultsTableView.reloadData()
                        self.geoSearchTextField.resignFirstResponder()
                    } else {
                        self.displayTextOnUI(errorString!)
                    }
                }
            }
        }
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    // MARK: - Confirm Location Function
    func ConfirmLocation(_ mapPointToCheck: MKMapItem) {
        resultForMapConfirmation = mapPointToCheck
        urlToBundle = urlTextField.text

        performSegue(withIdentifier: "ConfirmLocation", sender: self)
    }
    
    
    func displayTextOnUI(_ displayString: String) {
        debuggingTextField.alpha = 1.0
        debuggingTextField.text = displayString
        //fadeOutTextField(errorTextfield)
    }
    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ConfirmLocation" {
            let mapConfirmationVC = segue.destination as? MapConfirmationViewController
            mapConfirmationVC?.resultForMapConfirmation = resultForMapConfirmation
            mapConfirmationVC?.urlFromSegue = urlToBundle
        }
    }
}

extension InformationPostingViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if resultsFromSearch == nil {
            return 0
        }
        return resultsFromSearch!.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "returnedMapItemCell", for: indexPath)
        cell.textLabel?.text = resultsFromSearch![indexPath.row].name
        cell.isUserInteractionEnabled = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        resultForMapConfirmation = resultsFromSearch![indexPath.row]
        print("selected \(String(describing: resultForMapConfirmation?.name))")
        ConfirmLocation(resultForMapConfirmation!)
    }
}
