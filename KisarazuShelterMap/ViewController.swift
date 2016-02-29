//
//  ViewController.swift
//  KisarazuShelterMap
//
//  Created by Kouta on 2016/02/29.
//  Copyright © 2016年 Kouta. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

// 現在地の取得は後ほど
class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MapView
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 地図の中心を現在地にする
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)

        // 現在地をマーキング
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        
        // デリゲートの設定
        mapView.delegate = self
        
        let path = NSBundle.mainBundle().pathForResource("hinan", ofType: "csv")!
        if let data = NSData(contentsOfFile: path) {
            print(data)
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

