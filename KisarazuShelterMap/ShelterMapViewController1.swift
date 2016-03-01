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
import CSwiftV

class ShelterMapViewController1: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate {

    // MapView
    @IBOutlet weak var mapView: MKMapView!
    
    // LocationManager
    let locationManager = CLLocationManager()
    
    // 最後に位置情報を更新した場所
    var lastLocation: CLLocationCoordinate2D?

    // 避難場所の情報を格納する配列
    var shelter: [[String: String]] = []
    
    // 一時避難場所の情報を格納する配列
    var tempShelter: [[String: String]] = []
    
    // 避難場所と一時避難場所を表す識別子
    let shelterId = "SHELTER"
    let tempShelterId = "TEMPSHELTER"
    
    
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
        
        // 測位開始
        locationManager.startUpdatingLocation()
        
        // 避難場所情報hinan.csvを読み込み，配列shelterに格納
        shelter = readCSV("hinan")
        
        // 一時避難場所情報ichijihinan.csvを読み込み，配列tempShelterに格納
        tempShelter = readCSV("ichijihinan")
        
        // 避難場所にピンを設置
        setPins(shelter, id: shelterId)

        // 一時避難場所にピンを設置
        setPins(tempShelter, id: tempShelterId)
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
            
            // 現在地から5km四方で表示する
            let myRegion: MKCoordinateRegion = MKCoordinateRegionMakeWithDistance(location, 5000, 5000)
            mapView.setRegion(myRegion, animated: true)
        }

    }
    
    // アノテーション（ピン）の表示に関する設定
    func mapView(mapView: MKMapView, viewForAnnotation annotation: MKAnnotation) -> MKAnnotationView? {
        // 現在地のマークは変更しない
        if annotation is MKUserLocation {
            return nil
        }
        
        // 避難場所なのか一時避難場所なのかを判定
        let colorPointAnnotation = annotation as! ColorPointAnnotation
        let reuseId = colorPointAnnotation.id
        
        // reuseIdをもとにpinViewを取得
        var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(reuseId) as? MKPinAnnotationView
        // まだピンがなかったらピンを立てる
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            
            // idで色分け
            switch reuseId {
                // 避難場所は赤いピン
            case shelterId:
                pinView?.pinTintColor = UIColor.redColor()
                // 一時避難場所は緑のピン
            case tempShelterId:
                pinView?.pinTintColor = UIColor.greenColor()
            default:
                break
            }
            // アニメーションを付加
            pinView?.animatesDrop = true
            // ピンをタップした時にCalloutを表示
            pinView?.canShowCallout = true
        }
            // すでにピンが立っていたら再利用
        else {
            pinView?.annotation = annotation
        }
        
        return pinView
    }
    
    // CSVファイルを読み込みディクショナリ形式で返す
    func readCSV(fileName: String) -> [[String: String]] {
        if let path = NSBundle.mainBundle().pathForResource(fileName, ofType: "csv") {
            do {
                // pathのファイルを文字列として読む込む
                let csvString = try NSString(contentsOfFile: path, encoding: NSUTF8StringEncoding) as String
                // CSVをparseする ライブラリCSwiftVを用いることで簡単にディクショナリ形式にすることが可能
                let csv = CSwiftV(String: csvString).keyedRows!
                // parseしたものを返す
                return csv
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }
        // デフォルトでは何も返さない
        return []
    }
    
    // ピンを表示する
    func setPins(points: [[String: String]], id: String) {
        for point in points {
            // 配列から緯度経度を抽出
            let lat = NSString(string: point["latitude"]!).doubleValue
            let lng = NSString(string: point["longitude"]!).doubleValue
            // ピンのインスタンスを生成
            let pin = ColorPointAnnotation(id: id)
            // ピンの座標を設定
            pin.coordinate = CLLocationCoordinate2DMake(lat, lng)
            // ピンをタップした時に表示されるもの
            pin.title = NSString(string: point["place"]!) as String
            pin.subtitle = NSString(string: point["address"]!) as String
            // ピンを追加
            mapView.addAnnotation(pin)
        }
    }

}


