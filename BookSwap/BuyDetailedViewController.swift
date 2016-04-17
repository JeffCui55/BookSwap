//
//  BuyDetailedViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/2/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit
import CoreMotion
import MapKit
import CoreLocation

class BuyDetailedViewController: UIViewController, CLLocationManagerDelegate {

    @IBOutlet weak var titleText: UILabel!
    var titleName = String()
    @IBOutlet weak var ISBNText: UILabel!
    var ISBNName = String()
    @IBOutlet weak var ContactText: UILabel!
    var ContactName = String()
    
    var locationManager:CLLocationManager?
    
    @IBOutlet weak var lat: UILabel!
    @IBOutlet weak var long: UILabel!
    var currentLocation:CLLocation!
    
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444) //currentLocation
        centerMapOnLocation(initialLocation)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        titleText.text = titleName
        ISBNText.text = ISBNName
        ContactText.text = ContactName
        
    }
    
    override func viewDidLayoutSubviews(){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        //let screenHeight = screenSize.height
        self.scrollView.contentSize = CGSizeMake(screenWidth * 0.9, 2000);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func displayAlertWithTitle(title: String, message: String){
        let controller = UIAlertController(title: title,
                                           message: message,
                                           preferredStyle: .Alert)
        
        controller.addAction(UIAlertAction(title: "OK",
            style: .Default,
            handler: nil))
        
        presentViewController(controller, animated: true, completion: nil)
        
    }
    
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        if locations.count == 0{
            //handle error here
            return
        }
        
        let newLocation = locations[0]
        currentLocation = newLocation
        print("Latitude = \(newLocation.coordinate.latitude)")
        print("Longitude = \(newLocation.coordinate.longitude)")
        lat.text = String(newLocation.coordinate.latitude)
        long.text = String(newLocation.coordinate.longitude)
        
    }
    
    func locationManager(manager: CLLocationManager,
                         didFailWithError error: NSError){
        print("Location manager failed with error = \(error)")
    }
    
    func locationManager(manager: CLLocationManager,
                         didChangeAuthorizationStatus status: CLAuthorizationStatus){
        
        print("The authorization status of location services is changed to: ", terminator: "")
        
        switch CLLocationManager.authorizationStatus(){
        case .AuthorizedAlways:
            print("Authorized")
        case .AuthorizedWhenInUse:
            print("Authorized when in use")
        case .Denied:
            print("Denied")
        case .NotDetermined:
            print("Not determined")
        case .Restricted:
            print("Restricted")
        }
        
    }
    
    func createLocationManager(startImmediately startImmediately: Bool){
        locationManager = CLLocationManager()
        if let manager = locationManager{
            print("Successfully created the location manager")
            manager.delegate = self
            if startImmediately{
                manager.startUpdatingLocation()
            }
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        /* Are location services available on this device? */
        if CLLocationManager.locationServicesEnabled(){
            
            /* Do we have authorization to access location services? */
            switch CLLocationManager.authorizationStatus(){
            case .AuthorizedAlways:
                /* Yes, always */
                createLocationManager(startImmediately: true)
            case .AuthorizedWhenInUse:
                /* Yes, only when our app is in use */
                createLocationManager(startImmediately: true)
            case .Denied:
                /* No */
                displayAlertWithTitle("Not Determined",
                                      message: "Location services are not allowed for this app")
            case .NotDetermined:
                /* We don't know yet, we have to ask */
                createLocationManager(startImmediately: false)
                if let manager = self.locationManager{
                    manager.requestWhenInUseAuthorization()
                }
            case .Restricted:
                /* Restrictions have been applied, we have no access
                 to location services */
                displayAlertWithTitle("Restricted",
                                      message: "Location services are not allowed for this app")
            }
            
            
        } else {
            /* Location services are not enabled.
             Take appropriate action: for instance, prompt the
             user to enable the location services */
            print("Location services are not enabled")
        }
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
