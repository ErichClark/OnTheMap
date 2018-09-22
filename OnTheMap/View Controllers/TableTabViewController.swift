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
    
    var mapClient: MapClient!
    var mapCenter: CLLocationCoordinate2D? = nil
    var allStudents: [VerifiedStudentPin]? = nil
    
    var locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // get the Map client
        mapClient = MapClient.sharedInstance()
        allStudents = mapClient.allStudents
        

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Actions
    @IBAction func logOut(_ sender: Any) {
    }
    
    @IBAction func reload(_ sender: Any) {
    }
    
    @IBAction func addEntry(_ sender: Any) {
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
        let urlString = "\(allStudents![indexPath.row].url)"
        cell.detailTextLabel?.text = urlString
        cell.imageView?.image = UIImage(named: "icon_pin")
     
        return cell
    }

    /*
    // TODO: - Navigation - segue with mapCenter cordinate as map center in MapView

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
