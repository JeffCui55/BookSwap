//
//  ChooseLocationViewController.swift
//  BookSwap
//
//  Created by John Zhang on 4/28/16.
//  Copyright © 2016 Jeffery Cui. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

protocol ChooseLocationViewControllerDelegate {
    func setMeetLocation(latitude: Double, longitude: Double)
}

class ChooseLocationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    @IBOutlet weak var mapView: MKMapView!
    
    var delegate: ChooseLocationViewControllerDelegate?
    var latitude: Double!
    var longitude: Double!
    
    var currentLocation:CLLocation! = CLLocation()
    var annotation = MKPointAnnotation()
    var locationManager:CLLocationManager?
    var tap:UITapGestureRecognizer = UITapGestureRecognizer()
    
    var firstCenter: Bool = true
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mapView.delegate = self
        self.locationManager?.delegate = self
        //let initialLocation = CLLocation(latitude: GPSY, longitude: GPSX)
        locationManager?.startUpdatingLocation()
        //let initialLocation = currentLocation
        //centerMapOnLocation(currentLocation)
        //annotation.coordinate = CLLocationCoordinate2D(latitude: GPSY, longitude: GPSX)
//        annotation.coordinate = CLLocationCoordinate2D(latitude: currentLocation.coordinate.latitude, longitude: currentLocation.coordinate.longitude)
//        annotation.title = "Book Swap"
//        annotation.subtitle = "Meet to sell your book!"
//        mapView.addAnnotation(annotation)
        
        tap = UITapGestureRecognizer(target: self, action: #selector(ChooseLocationViewController.addPin))
        
        mapView.addGestureRecognizer(tap)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func setLocation(sender: AnyObject) {
        if(latitude == nil || longitude == nil){
            let alertString = "Please set a location!"
            let alert = UIAlertController(title: "Incomplete", message: alertString, preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Got it!", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)

        }else{
            delegate?.setMeetLocation(latitude, longitude: longitude)
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    
    // Mark - MKMapViewDelegate methods
    
    let regionRadius: CLLocationDistance = 1000
    func centerMapOnLocation(location: CLLocation) {
        let coordinateRegion = MKCoordinateRegionMakeWithDistance(location.coordinate,
                                                                  regionRadius * 2.0, regionRadius * 2.0)
        mapView.setRegion(coordinateRegion, animated: true)
    }
    
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? MKAnnotation? {
            let identifier = "pin"
            var view: MKPinAnnotationView
            if let dequeuedView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier)
                as? MKPinAnnotationView { // 2
                dequeuedView.annotation = annotation
                view = dequeuedView
            } else {
                // 3
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
                view.canShowCallout = true
                view.calloutOffset = CGPoint(x: -5, y: 5)
                view.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            }
            return view
        }
        return nil
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
        //print("location manager called")
        if locations.count == 0{
            //handle error here
            print("No locations")
            return
        }
        
        // let newLocation = locations[0]
        let newLocation = locations.last! // as CLLocation
        currentLocation = newLocation
        if(firstCenter) {
            centerMapOnLocation(currentLocation)
            firstCenter = false
        }
        
        //        print("Latitude = \(newLocation.coordinate.latitude)")
        //        print("Longitude = \(newLocation.coordinate.longitude)")
        //        lat.text = String(newLocation.coordinate.latitude)
        //        long.text = String(newLocation.coordinate.longitude)
        //lat.text = String(GPSY)
        //long.text = String(GPSX)
        
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

    func addPin() {
        var touchPoint:CGPoint = tap.locationInView(self.view)
        var touchMapCoordinate: CLLocationCoordinate2D = self.mapView.convertPoint(touchPoint, toCoordinateFromView: self.mapView)

        annotation.coordinate = touchMapCoordinate
        latitude = annotation.coordinate.latitude
        longitude = annotation.coordinate.longitude
        //annotation.title = "Book Swap"
        //annotation.subtitle = "Meet to sell your book!"
    
        mapView.addAnnotation(annotation)
        print(latitude, longitude)
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
