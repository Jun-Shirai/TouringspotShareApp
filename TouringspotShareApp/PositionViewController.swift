//
//  PositionViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/03/02.
//

import UIKit
import GoogleMaps

class PositionViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {
    
    var mapView = GMSMapView()  //マップを表示するため
    var locationManager = CLLocationManager()  //位置情報取得のため
    var marker: GMSMarker?  //最初はマーカーがない状態（nil）だから、オプショナル型で宣言しておこう。var marker = GMSMarker()だと初期値で宣言してしまうから画面上にマーカーはないけど、「コード上ではマーカーが存在する（緯度経度０）」ことになってしまう。
    @IBOutlet weak var tableView: UITableView!  //マップ表示をする場所を指定するために
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //グーグルマップの初期位置を指定（今回は東京駅付近）
        let camera = GMSCameraPosition.camera(withLatitude: 35.6828335, longitude: 139.7598972, zoom: 17.0)
        mapView = GMSMapView.map(withFrame: CGRect(origin: .zero, size: view.bounds.size), camera: camera)
        
        mapView.delegate = self
        mapView.settings.myLocationButton = true  //右下のボタン、押すと自身の位置まで画面が戻る
        mapView.isMyLocationEnabled = true  //位置情報取得のため記述
        
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()  //位置情報の取得許可「アプリ使用中のみ」の確認をとるダイアログ表示の生成
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  //取得精度の設定
        locationManager.startUpdatingLocation()  //現在地の更新
        
        self.tableView.addSubview(mapView)
        self.tableView.bringSubviewToFront(mapView)
        
    }
    
    //現在地が更新されたら呼び出す→アプリ起動時に現在地を初期表示とするために処理
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 17.0)
        
        self.mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
    
    //選んだ位置を長押ししたときに呼び出すメソッド
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        //マーカー既に存在してるか否かで場合分けして、マーカー表示を一つだけにする。
        if self.marker == nil {
            self.marker = GMSMarker(position: coordinate)
            print("マーカーないからつくるよ")
        }else {
            self.marker?.map = nil
            print("マーカー消すよ")
            self.marker = GMSMarker(position: coordinate)
            print("マーカーつくるよ")
        }
        //マーカー表示
        self.marker?.map = mapView
        
        //座標の取得→文字列に変換する
        let latStr = coordinate.latitude.description
        let lonStr = coordinate.longitude.description
        //確認用
        print("lat : " + latStr)
        print("lon : " + lonStr)
        
        //投稿画面を取得して緯度・経度欄に文字を渡す
        let giveStr = self.presentingViewController as! PostViewController
        giveStr.latitudeTextField.text = latStr.description
        giveStr.longitudeTextField.text = lonStr.description
        
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
