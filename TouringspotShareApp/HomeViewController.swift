//
//  HomeViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/02/26.
//

import UIKit
import GoogleMaps
import Firebase

class HomeViewController: UIViewController,CLLocationManagerDelegate,GMSMapViewDelegate {
    
    var mapView = GMSMapView()  //マップを表示するため
    var locationManager = CLLocationManager()  //位置情報取得のため
    var postArray: [PostData] = []  //複数ある投稿データを配列して格納する
    var markers: [GMSMarker] = []  //複数あるマーカーを配列して格納する
    var listener: ListenerRegistration?  //Firestoreのリスナー
    var lati: CLLocationDegrees!  //マーカー表示用
    var longi: CLLocationDegrees!  //マーカー表示用
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        //グーグルマップの初期位置を指定（今回は東京駅付近）
        let camera = GMSCameraPosition.camera(withLatitude: 35.6828335, longitude: 139.7598972, zoom: 17.0)
        mapView = GMSMapView.map(withFrame: CGRect(origin: .zero, size: view.bounds.size), camera: camera)
        mapView.settings.myLocationButton = true  //右下のボタン、押すと自身の位置まで画面が戻る
        mapView.isMyLocationEnabled = true  //位置情報取得のため記述
        mapView.delegate = self
        
        //リスナーで使用してFirebase内の投稿データの更新を監視して、全ての投稿データ（マーカー）を地図上に反映させる処理を行いたいが、記述方法がわからない
        //ログイン済みかどうかを確認
        if Auth.auth().currentUser != nil {

            //listenerを登録して投稿データの更新を監視する
            let postsRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            //addSnapshotListenerメソッドがpostrefで取得する投稿データを監視し、投稿データが追加される・更新される度にクロージャ内の処理が呼び出される
            listener = postsRef.addSnapshotListener() {(querySnapshot,error) in  //querySnapshotに最新の投稿データが入っている。
                if let error = error {
                    print("DEBUG_PRINT: snapshotの取得に失敗しました。 \(error)")
                    return
                }
                //取得したdocumentをもとにPostDataを作成し、更新された（新しいデータを含んだ）postDataをpostArrayの配列にする
                //＊mapメソッドは新しい投稿データを新しい配列に変換して作成してくれる
                self.postArray = querySnapshot!.documents.map { document in
                    let postData = PostData(document: document)
                    return postData
                }
                //makeMarkerメソッドを使用して複数ある投稿データを一つずつマップ上にマーカーを表示させる
                for element in self.postArray {
                    self.makeMarker(postData: element)
                }

            }
        }

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()  //位置情報の取得許可「アプリ使用中のみ」の確認をとるダイアログ表示の生成
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  //取得制度の設定
        locationManager.startUpdatingLocation()  //位置情報の取得開始
        
        self.view.addSubview(mapView)
        self.view.bringSubviewToFront(mapView)
        
    }
    
    //現在地が更新されたら呼び出す→アプリ起動時に現在地を初期表示とするために処理
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 17.0)
        
        self.mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
    
    //PostDataクラスから投稿データの緯度・経度を引っ張って、マーカーを表示させる
    func makeMarker(postData: PostData) {  //->[GMSMarker]
        //PostDataクラスの緯度・経度をString→Doubleに変換
        let posLati: String = postData.latitude!
        let posLongi: String = postData.longitude!
        lati = Double(posLati)
        longi = Double(posLongi)
        
        //地図上に投稿データの数だけマーカーを表示させる
        let marker: GMSMarker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lati, longitude: longi)
        marker.map = mapView  //マップ上に表示
        markers.append(marker)  //新たなマーカーを配列に追加
//        return markers
    }
    
    //マーカーをタップしたら該当の投稿データ閲覧画面にモーダル遷移（ShowViewController）
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //タップされたマーカーの特定をして、postDataとして遷移先にデータを渡す
        //マーカーの緯度・経度をDouble→Stringに変換する必要あり？
        marker.position = CLLocationCoordinate2D(latitude: lati, longitude: longi)
        let point = marker.position
        let indexPath = mapView.index(ofAccessibilityElement: point)
        let postData = postArray[indexPath]
        
        let showViewController = storyboard!.instantiateViewController(withIdentifier: "Show") as! ShowViewController
        showViewController.postData = postData
        present(showViewController, animated: true, completion: nil)
        
        
        return false  //吹き出しの代わりに画面遷移と値渡し
    }
    
    //画面表示領域のみマーカーを表示（データ処理が重くなるのを軽減）
    
    
    //画面内の表示マーカー数が多いとき、まとめて表示するマーカーを生成（見やすくするため）
    
    
    //投稿日から一年したら投稿データが削除される処理
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
