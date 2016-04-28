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

class BuyDetailedViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

    @IBOutlet weak var titleText: UILabel!
    var titleName = String()
    @IBOutlet weak var ISBNText: UILabel!
    var ISBNName = String()
    @IBOutlet weak var ContactText: UILabel!
    var ContactName = String()
    
    var locationManager:CLLocationManager?
    
    @IBOutlet weak var editionText: UILabel!
    var editionName = String()
    @IBOutlet weak var phoneText: UILabel!
    var phoneNumName = String()
    
    @IBOutlet weak var personText: UILabel!
    var personName = String()
    @IBOutlet weak var authorText: UILabel!
    var authorName = String()
    @IBOutlet weak var priceText: UILabel!
    var priceName: Double = 0.0
    
    @IBOutlet weak var qualityText: UILabel!
    var qualityName = String()
    
    @IBOutlet weak var subjectText: UILabel!
    var subjectName = String()
    @IBOutlet weak var descriptionText: UILabel!
    var descriptionName = " "
    @IBOutlet weak var dateText: UILabel!
    var dateName = NSDate()
    var GPSY:Double!
    var GPSX:Double!
    
    var currentLocation:CLLocation!
    var annotation = MKPointAnnotation()
    @IBOutlet weak var mapView: MKMapView!
    
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var theImage: UIImageView!
    var theImagevar:UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.tintColor = UIColor.whiteColor()
//        let initialLocation = currentLocation
//        let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
        self.mapView.delegate = self
        let initialLocation = CLLocation(latitude: GPSY, longitude: GPSX)
        centerMapOnLocation(initialLocation)
        annotation.coordinate = CLLocationCoordinate2D(latitude: GPSY, longitude: GPSX)
        annotation.title = "Book Swap"
        annotation.subtitle = "Meet to sell your book!"
        mapView.addAnnotation(annotation)
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        titleText.text = titleName
        ISBNText.text = ISBNName
        ContactText.text = ContactName
        phoneText.text = phoneNumName
        priceText.text = String(priceName)
        qualityText.text = qualityName
        editionText.text = editionName
        subjectText.text = subjectName
        descriptionText.text = descriptionName
        authorText.text = authorName
        personText.text = personName
//        descriptionText.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
//        descriptionText.numberOfLines = 0
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "MM/dd/YYYY"
        let strdate = dateFormatter.stringFromDate(dateName)
        print(strdate)
        dateText.text = strdate
//        dateText.lineBreakMode = .ByWordWrapping // or NSLineBreakMode.ByWordWrapping
//        dateText.numberOfLines = 0
        theImage.image = theImagevar
        theImage.contentMode = .ScaleAspectFit
        
    }
    
    override func viewDidLayoutSubviews(){
        let screenSize: CGRect = UIScreen.mainScreen().bounds
        let screenWidth = screenSize.width
        //let screenHeight = screenSize.height
        self.scrollView.contentSize = CGSizeMake(screenWidth * 0.9, mapView.frame.height + mapView.frame.origin.y + 30);
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
        
        if locations.count == 0{
            //handle error here
            return
        }
        
        let newLocation = locations[0]
        currentLocation = newLocation
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
