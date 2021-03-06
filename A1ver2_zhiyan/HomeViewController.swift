//
//  HomeViewController.swift
//  A1ver2_zhiyan
//
//  Created by steven liu on 1/9/19.
//  Copyright © 2019 steven liu. All rights reserved.
//
// reference: https://www.youtube.com/watch?v=SayMogu530A&list=PLwh-fNUJO9t56qDQP8HzbNjVuNkGzZT5c


import UIKit
import MapKit
import CoreData

//protocol SightSelectDelegate {
//   func didSightSelect(_ tapedSight : SightEntity)
//}


class HomeViewController: UIViewController, DatabaseListener {

    func onSightListChange(change: DatabaseChange, sightsDB: [SightEntity]) {
        for s in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: s)
        }
        sights = sightsDB     //update sights by database
        
        for s in sights {      // update genfencing
             setGeofen(sight: s)
        }
    }
    
  //  var sightSelectDelegate : SightSelectDelegate?
    
    private let locationManager = CLLocationManager()
    private var currentCoordinate: CLLocationCoordinate2D?
    var selectedSight : SightEntity?
    var sights : [SightEntity] = []
    weak var databaseController : DatabaseProtocol?
    weak var addSightDelegate: AddSightDelegate?
    
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        databaseController = appDelegate.databaseController   //coredata
        
        mapView.delegate = self
        configureLocationServices()
        print("homeview controller 1111")
        // Do any additional setup after loading the view.
           //detail page
      
    }
   

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "sightListSegue" {
            let destination = segue.destination as! SightsTableViewController
            destination.focusSightDelegate = self
        }
    }
 
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
      
       databaseController?.addListener(listener: self)
      removeAllAnnotations()
       addAnnotations()
     
       
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        databaseController?.removeListener(listener: self)
    }
    var listenerType = ListenerType.sight
    
   
    
    private func configureLocationServices() {
        locationManager.delegate = self
        let status = CLLocationManager.authorizationStatus()
        if  status == .notDetermined {
            locationManager.requestAlwaysAuthorization()
        } else if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: locationManager)
        }
    }
    
    private func beginLocationUpdates(locationManager : CLLocationManager) {
        mapView.showsUserLocation = true
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    private func zoomToLatestLocation(with coordinate : CLLocationCoordinate2D) {
        
        let zoomRegion = MKCoordinateRegion(center: coordinate,latitudinalMeters: 5000,longitudinalMeters: 5000)
        mapView.setRegion(mapView.regionThatFits(zoomRegion), animated: true)
    }
    
    private func addAnnotations() {
//        let myAnnotation = MKPointAnnotation()
//        myAnnotation.title = "Parliament House of Victoria"
//        myAnnotation.coordinate = CLLocationCoordinate2D(latitude: -37.832380, longitude: 144.960430)
        
      //  mapView.addAnnotation(myAnnotation)
        for s in sights {
             addSightAnnotation(sight: s)
            
//            if let latitude = Double(s.latitude!), let longitude = Double(s.longitude!), let identifier = s.name {
//                setGeofencing(lat: latitude, lon: longitude, radius: 200, identifier: identifier)
//            }
            
        }
       
    }
    
    func removeAllAnnotations() {
        let annotations = mapView.annotations.filter {
            $0 !== self.mapView.userLocation
        }
        mapView.removeAnnotations(annotations)
        
    }
    
    private func addSightAnnotation(sight: SightEntity) {
        let myAnnotation = MKPointAnnotation()
        myAnnotation.title = sight.name
      //  myAnnotation.subtitle = sight.desc
        if let lat = Double(sight.latitude!), let lon = Double(sight.longitude!) {
               myAnnotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: lon)
          //  setGeofencing(lat: lat, lon: lon, radius: 500, identifier: sight.name!, set: true)   //geofencing
        } else {
            print("invalid coordinate")
            return
        }
        
        mapView.addAnnotation(myAnnotation)
//        if let latitude = Double(myAnnotation.latitude!), let longitude = Double(myAnnotation.longitude!), let identifier = myAnnotation.name {
//            setGeofencing(lat: latitude, lon: longitude, radius: 500, identifier: identifier, set: true)
//        }
    }
    
    
}

extension HomeViewController : CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        guard let latestLocation = locations.first else { return}
       
        
     //   if currentCoordinate == nil {
           // zoomToLatestLocation(with: latestLocation.coordinate)
        //    addAnnotations()
       // }
        zoomToLatestLocation(with: latestLocation.coordinate)
        currentCoordinate = latestLocation.coordinate
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            beginLocationUpdates(locationManager: manager)
        }
    }
    
}

extension HomeViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: "AnnotationView")
        if annotationView == nil {
            annotationView = MKAnnotationView(annotation: annotation, reuseIdentifier: "AnnotationView")
        }
        
        
//        if annotation.title == "Parliament House of Victoria" {
//            //annotationView?.image = resizeImage(iniImage: #imageLiteral(resourceName: "Public Record Office Victoria"))
//
//
//            annotationView?.image = #imageLiteral(resourceName: "Victoria's Parliament House")
//            annotationView?.frame.size = CGSize(width: 60, height: 40)
//
//        }  else
        for s in sights {
            if annotation.title == s.name {
               let image = UIImage(data: s.image! as Data)
                annotationView?.image = UIImage(named: s.icon ?? "museum")
                configureDetailView(annotationView: annotationView!, image: image!)
                configureRightView(annotationView: annotationView!,tagNum: sights.firstIndex(of: s) ?? 0 )
             //   configureLeftView(annotationView: annotationView!, iconName: s.icon ?? "museum")
                annotationView?.frame.size = CGSize(width: 50, height: 50)

                break
            }
        }
//        annotationView?.image = #imageLiteral(resourceName: "Victoria's Parliament House")
//        annotationView?.frame.size = CGSize(width: 60, height: 40)
        
            if annotation === mapView.userLocation {
                annotationView?.image = #imageLiteral(resourceName: "avatar")
            annotationView?.frame.size = CGSize(width: 50, height: 50)
            }
        
        annotationView?.canShowCallout = true
        
      
      
        
//        configureDetailView(annotationView: annotationView!)
        return annotationView
        }
    
    func configureDetailView(annotationView: MKAnnotationView, image : UIImage) {
        
        let detailView = UIImageView( image: image)
        
//        let descView = UITextView.init()
//        descView.text = "sfjsklfjdslfjdlsfkjdslfjdkls"
//        detailView.addSubview(descView)
       
        let views = ["snapshotView": detailView]
        detailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[snapshotView(300)]", options: [], metrics: nil, views: views))
        detailView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[snapshotView(200)]", options: [], metrics: nil, views: views))
    
        annotationView.detailCalloutAccessoryView = detailView
    }
    
    func configureRightView(annotationView: MKAnnotationView, tagNum : Int){
        let rightButton = UIButton(type: .detailDisclosure)
        rightButton.tag = tagNum
        annotationView.rightCalloutAccessoryView = rightButton
    }
    
//    func configureLeftView(annotationView : MKAnnotationView, iconName : String)
//    {
//       let leftView = UIImageView()
//       leftView.image = #imageLiteral(resourceName: "museum")
//        let views = ["iconView": leftView]
//        leftView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:[iconView(30)]", options: [], metrics: nil, views: views))
//        leftView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:[iconView(20)]", options: [], metrics: nil, views: views))
//       annotationView.leftCalloutAccessoryView = leftView
//
//    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        let buttonNum = control.tag
//        let detailScreen = storyboard?.instantiateViewController(withIdentifier: "Sight Detail") as! DetailViewController
//        present(detailScreen, animated: true, completion: nil)
        selectedSight = sights[buttonNum]
     //   print(selectedSight!.name)
//        self.sightSelectDelegate = DetailViewController()
       if selectedSight != nil {
//            sightSelectDelegate?.didSightSelect(selectedSight!)
         //dismiss(animated: true, completion: nil)
        let detailScreen = storyboard?.instantiateViewController(withIdentifier: "Sight Detail") as! DetailViewController
        detailScreen.selectedSight = selectedSight!
            present(detailScreen, animated: true, completion: nil)
    //  dismiss(animated: true, completion: nil)
//    }
        }
    }
        
    func resizeImage(iniImage : UIImage) -> UIImage {
        // Resize image
        let pinImage = iniImage
        let size = CGSize(width: 50, height: 50)
        UIGraphicsBeginImageContext(size)
        pinImage.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        return resizedImage!
    }
    
    
//    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
//
//    }
   // https://www.raywenderlich.com/5470-geofencing-with-core-location-getting-started
    
   
    
    func setGeofen (sight : SightEntity)
    {
        let lat = Double(sight.latitude!)!
        let lon = Double(sight.longitude!)!
        let geofenceRegionCenter = CLLocationCoordinate2D(latitude: lat ,longitude: lon)
        let geofenceRegion = CLCircularRegion(
            center: geofenceRegionCenter,
            radius: 500,
            identifier: sight.name!
        )
        
        geofenceRegion.notifyOnEntry = true
        geofenceRegion.notifyOnExit = true
        self.locationManager.startMonitoring(for: geofenceRegion)
    }
    
}

extension HomeViewController : FocusSightDelegate {
    func foucusSight(sight: SightEntity) {
        if let lat = Double(sight.latitude!), let lon = Double(sight.longitude!) {
          let coordinate =  CLLocationCoordinate2D(latitude: lat, longitude: lon)
            zoomToLatestLocation(with: coordinate)
            
        }
    }
    
    
}






  
    


    
   

