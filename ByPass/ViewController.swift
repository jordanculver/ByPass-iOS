//
//  ViewController.swift
//  ByPass
//
//  Created by Eswari Mylavarapu on 5/19/17.
//  Copyright © 2017 American Airlines. All rights reserved.
//

import UIKit
//import CoreBluetooth
import CoreLocation
import SwiftHTTP

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var bypassWebView: UIWebView!
    let locationManager = CLLocationManager()
    let unknown: String = "Unknown"
//    var myBeaconRegion: CLBeaconRegion
//    var locationManager: CLLocationManager

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        NSUUID uuid = NSUUID()
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        //5C3F2F21-20D1-11E6-A9BB-06481FD16E71
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "")!, identifier: "beaconRegion")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

//    func checkIfBlueToothEnabled() {
//        centralManager = CBCentralManager(delegate: self, queue: nil, options:null)
//    }

//    func listenForBeacon(){
//        
//    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let beacon = beacons.last
        
        if (beacons.count > 0) {
            let uuid = beacon?.proximityUUID.uuidString
            let major = beacon?.major.stringValue
            let minor = beacon?.minor.stringValue
            let isCloseBy = CLProximity.far == beacon?.proximity
            if (isCloseBy) {
                let bypassUrl = NSURL(string: "https://www.google.com#q=uuid+is+\(uuid ?? unknown)+major+is+\(major ?? unknown)+minor+is+\(minor ?? unknown)")
                let requestObj = NSURLRequest(url: bypassUrl! as URL)
                sendBeaconRequest(uuid: uuid!, major: major!, minor: minor!, recordLocator: retrieveRecordLocatorFromAccount())
                bypassWebView.loadRequest(requestObj as URLRequest)
            }
        }
    }
    
//    func sendBeaconRequest(uuid: String, major: String, minor: String, recordLocator: String) {
//        let url = URL(string: "http://207.138.132.95:8600/beaconRequest")
//        var request = URLRequest(url: url!)
//        request.httpMethod = "POST"
//        request.httpBody = "uuid=\(uuid)&major=\(major)&minor=\(minor)&recordLocator=\(recordLocator)".data(using: .utf8)
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            
//            guard let data = data, error == nil else {
//                //bypassWebView set to error page
//                print("error=\(String(describing: error))")
//                return
//            }
//            
//            if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {           // check for http errors
//                //bypassWebView set to error page
//                print("statusCode should be 200, but is \(httpStatus.statusCode)")
//                print("response = \(String(describing: response))")
//            }
//            
//            let responseString = String(data: data, encoding: .utf8)
//            print("response=\(String(describing: responseString))")
//            //bypassWebView set to success page
//        }
//        task.resume()
//    }
    
    func sendBeaconRequest(uuid: String, major: String, minor: String, recordLocator: String) {
        let params = ["recordLocator": "777", "beacon": [
            "minor": "someVal",
            "UUID": "someVal",
            "major": "someVal"]] as [String : Any]
        do {
            let opt = try HTTP.POST("http://207.138.132.95:8600/beaconRequest", parameters: params)
            opt.start { response in
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    return
                }
                let jsonData = try? JSONSerialization.jsonObject(with: response.data, options: [])
                
                guard let customerData = jsonData as? [String: Any], let _ = customerData["customerData"] as? [String: Any] else {
                    return
                }
            }
            print("Success!")
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    func retrieveRecordLocatorFromAccount() -> String {
        return "123456"
    }
}

