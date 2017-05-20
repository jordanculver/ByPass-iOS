//
//  ViewController.swift
//  ByPass
//
//  Created by Eswari Mylavarapu on 5/19/17.
//  Copyright © 2017 American Airlines. All rights reserved.
//

import UIKit
import CoreLocation
import SwiftHTTP

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var bypassWebView: UIWebView!
    static let failureUrl: String = "https://fn-1337-bypass-web.mybluemix.net/failure.html"
    static let boardedUrl: String = "https://fn-1337-bypass-web.mybluemix.net/boarded.html"
    static let homeUrl: String = "https://fn-1337-bypass-web.mybluemix.net/"
//    static let boardRequestUrl: String = "http://207.138.132.95:8600/beaconRequest"
    
    static let boardRequestUrl: String = "https://fn-1337-node-red-starter.mybluemix.net/bypass"
    
    let locationManager = CLLocationManager()
    let unknown: String = "Unknown"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
        let beaconRegion = CLBeaconRegion(proximityUUID: UUID(uuidString: "5C3F2F21-20D1-11E6-A9BB-06481FD16E71")!, identifier: "beaconRegion")
        locationManager.startMonitoring(for: beaconRegion)
        locationManager.startRangingBeacons(in: beaconRegion)
        loadBypassWebView(url: ViewController.homeUrl)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func locationManager(_ manager: CLLocationManager, didRangeBeacons beacons: [CLBeacon], in region: CLBeaconRegion) {
        let beacon = beacons.last
        
        if (beacons.count > 0) {
            let uuid = beacon?.proximityUUID.uuidString
            let major = beacon?.major.stringValue
            let minor = beacon?.minor.stringValue
            let isCloseBy = CLProximity.near == beacon?.proximity
            if (isCloseBy) {
                
                sendBeaconRequest(uuid: uuid!, major: major!, minor: minor!, recordLocator: retrieveRecordLocatorFromAccount())
            }
        }
    }
    
    func sendBeaconRequest(uuid: String, major: String, minor: String, recordLocator: String) {
        let params = ["recordLocator": "\(recordLocator)", "beacon": [
            "minorID": "\(minor)",
            "UUID": "\(uuid)",
            "majorID": "\(major)"]] as [String : Any]
        do {
            let opt = try HTTP.POST(ViewController.boardRequestUrl, parameters: params)
            opt.start { response in
            
                if let err = response.error {
                    print("error: \(err.localizedDescription)")
                    self.loadBypassWebView(url: ViewController.failureUrl)
                    return
                }
                
                self.checkForFailure(data: response.data)

//                self.loadBypassWebView(url: ViewController.boardedUrl)
                // notify user (notification/alert)
            }
        } catch let error {
            print("got an error creating the request: \(error)")
        }
    }
    
    func loadBypassWebView(url: String) {
        URLCache.shared.removeAllCachedResponses()
        URLCache.shared.diskCapacity = 0
        URLCache.shared.memoryCapacity = 0
        let bypassUrl = NSURL(string: url)
        let requestObj = NSURLRequest(url: bypassUrl! as URL)
        bypassWebView.loadRequest(requestObj as URLRequest)
    }
    
    func retrieveRecordLocatorFromAccount() -> String {
        return "123456"
    }
    
    func checkForFailure(data: Data) {
    
//        let jsonData = try? JSONSerialization.jsonObject(with: data, options: [])
//        guard let customerData = jsonData as? [String: Any], let _ = customerData["customerData"] as? [String: Any] else {
//            return
//        }
        let res = self.dictionaryWithContentsOfJSON(data: data)
        if ("boardingFailure" == res?["pageNavigation"] as? String) {
            loadBypassWebView(url: ViewController.failureUrl)
        } else if ("boardingSuccess" == res?["pageNavigation"] as? String) {
            loadBypassWebView(url: ViewController.boardedUrl)
        }
    }
    
    /// Returns a dictionary after deserializing the JSON located at the provided
    /// URL.
    ///
    /// - Parameter url: The URL of the JSON file.
    /// - Returns: The JSON file deserialized as a Dictionary.
    func dictionaryWithContentsOfJSON(data: Data) -> [String: Any]? {
        
        do {
//            let jsonData = try Data(contentsOf: url)
            let dictionary = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            return dictionary
        } catch {
            NSLog("Unable to deserialize the dictionary from JSON %@:", error.localizedDescription)
        }
        
        return nil
    }

}
