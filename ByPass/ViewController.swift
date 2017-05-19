//
//  ViewController.swift
//  ByPass
//
//  Created by Eswari Mylavarapu on 5/19/17.
//  Copyright © 2017 American Airlines. All rights reserved.
//

import UIKit
import CoreBluetooth
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {
    @IBOutlet weak var bypassWebView: UIWebView!
//    var myBeaconRegion: CLBeaconRegion
//    var locationManager: CLLocationManager

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
//        self.locationManager = CLLocationManager()
//        self.locationManager.delegate = self
//        NSUUID uuid = NSUUID()
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
            let isCloseBy = CLProximity.near == beacon?.proximity
            if (isCloseBy) {
                let bypassUrl = NSURL(string: "https://www.google.com#q=uuid+is+\(uuid)+major+is+\(major)+minor+is+\(minor)")
                let requestObj = NSURLRequest(url: bypassUrl! as URL)
                bypassWebView.loadRequest(requestObj as URLRequest)
            }
        }
    }
}

