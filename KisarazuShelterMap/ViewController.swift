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

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MapView
    @IBOutlet weak var mapView: MKMapView!
    
    // LocationManager
    let locationManager = CLLocationManager()
    
    // 最後に位置情報を更新した場所
    var lastLocation: CLLocationCoordinate2D?

    // 避難場所の情報を格納する配列
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 地図の中心を現在地にする
        mapView.setCenterCoordinate(mapView.userLocation.coordinate, animated: true)

        // 現在地をマーキング
        mapView.userTrackingMode = MKUserTrackingMode.FollowWithHeading
        
        // デリゲートの設定
        mapView.delegate = self
        locationManager.delegate = self
        
        // 100m移動したら位置情報を更新する
        locationManager.distanceFilter = 100.0
        
        // 測位の精度を100mとする
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        
        // 位置情報サービスへの認証状態を取得
        let status = CLLocationManager.authorizationStatus()
        
        // 未認証ならばダイアログを出す
        if status == CLAuthorizationStatus.NotDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
        
        // 即位開始
        locationManager.startUpdatingLocation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 位置情報サービスへの認証状態がダイアログによって変更されたとき実行
    func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
        case CLAuthorizationStatus.AuthorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case CLAuthorizationStatus.AuthorizedAlways:
            locationManager.startUpdatingLocation()
        case CLAuthorizationStatus.Denied:
            print("Denied")
        case CLAuthorizationStatus.Restricted:
            print("Restricted")
        case CLAuthorizationStatus.NotDetermined:
            print("NotDetermined")
        }
    }
    
    // 位置情報が更新されたときに実行
    func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // 位置情報の配列から一番最後に取得した位置情報を取得
        let locations: NSArray = locations as NSArray
        let location: CLLocation = locations.lastObject as! CLLocation
        lastLocation = location.coordinate
        
        if let location = lastLocation {
            // 一番最後に取得した位置情報をマップの中心にする
            let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(lastLocation!.latitude, lastLocation!.longitude)
            mapView.setCenterCoordinate(center, animated: true)
            
            // 現在地から3km四方で表示する
            let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location, 5000, 5000)
            mapView.setRegion(myRegion, animated: true)
        }

    }

}


