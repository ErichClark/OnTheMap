//
//  TableTabViewController.swift
//  OnTheMap
//
//  Created by Erich Clark on 9/4/18.
//  Copyright © 2018 Erich Clark. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class TableTabViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var feedbackTextField: UITextField!
    @IBOutlet weak var studentTable: UITableView!
    
    var mapClient: MapClient!
    var dataSource: DataSource!
    var mapCenter: CLLocationCoordinate2D? = nil
    var allStudents: [VerifiedStudentPin]? = nil
    var logoutMessage: String? = nil
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the Map client
        mapClient = MapClient.sharedInstance()
        allStudents = DataSource.sharedInstance().allStudents
        feedbackTextField.isHidden = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        // MARK: - on a first run tableview does not exist yet, so comparing them will crash the app
        // This method checks if there are visible cells, then compares the visible cells with the
        // allStudents table in the data model. If not matching, reloads table.
        if studentTable.visibleCells.count != 0 {
            if studentTable.visibleCells[0] != DataSource.sharedInstance().allStudents![0] {
                reload(self)
            }
        } 
    }
    
    // MARK: - Actions
    @IBAction func logOut(_ sender: Any) {
        
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
        }
        
        displayTextOnUI("Logging out of Udacity...")
        mapClient.logOutOfUdacity() { (success, successMessage, errorMessage) in
            
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
                self.feedbackTextField.isHidden = true
            }
            performUIUpdatesOnMain {
                if success {
                    print(successMessage!)
                } else {
                    print(errorMessage!)
                }
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func reload(_ sender: Any)  {
        
        performUIUpdatesOnMain {
            self.activityIndicator.startAnimating()
            self.displayTextOnUI("Getting student locations...")
        }
        
        mapClient.getStudentLocations() {
            (success, allValidStudentLocations, errorString) in
            
            performUIUpdatesOnMain {
                self.activityIndicator.stopAnimating()
            }
            
            performUIUpdatesOnMain {
                if success {
                    self.feedbackTextField.isHidden = true
                    self.studentTable.reloadData()
                } else {
                    self.displayTextOnUI(errorString!)
                }
            }
        }
    }
    
    // MARK: - Display Text
    func displayTextOnUI(_ text: String){
        feedbackTextField.isHidden = false
        feedbackTextField.text = text
    }
    
    @IBAction func addPin(_ sender: Any) {
        performSegue(withIdentifier: "addPin", sender: self)
    }
    
    // MARK: - Table view data source

     func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

     func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allStudents!.count
    }
    
     func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "studentTableCell", for: indexPath)
        cell.textLabel?.text = allStudents![indexPath.row].name
        let urlString = "\(allStudents![indexPath.row].mediaURL)"
        cell.detailTextLabel?.text = urlString
        cell.imageView?.image = UIImage(named: "icon_pin")
     
        return cell
    }

    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let url = URL(string: String(allStudents![indexPath.row].mediaURL))
        
        if UIApplication.shared.canOpenURL(url!) {
            UIApplication.shared.open(url!, options: [:], completionHandler: {(success) in
                print("Open \(String(describing: url)) \(success)")})
        }
    }

}
