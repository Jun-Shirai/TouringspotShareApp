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

        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()  //位置情報の取得許可「アプリ使用中のみ」の確認をとるダイアログ表示の生成
        locationManager.desiredAccuracy = kCLLocationAccuracyBest  //取得制度の設定
        locationManager.startUpdatingLocation()  //位置情報の取得開始
        
        self.view.addSubview(mapView)
        self.view.bringSubviewToFront(mapView)
        
    }
    //他の画面から戻ってきても最新のデータを反映・更新している状態にする。＊viewDidloadだとログイン画面からきたとき最新のデータが反映されていない状況になるため。また稀に投稿後でも反映されていないときがあるため。
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("DEBUG_PRINT: viewWillAppear")
        
        //ShowViewControllerで投稿削除時に格納したキー（id）と一致するidを削除する
        if let delMarker: String = UserDefaults.standard.value(forKey: "delMarker") as? String {
            //for文でmarkers配列から一つずつ一致するもの探していく
            for marker in markers {
                let data = marker.userData as! PostData
                if (data.id == delMarker) {
                    print("hit: delete marker")
                    marker.map = nil
                }
            }
            
        }
        
        //投稿データの更新をもとにマップに最新の状態でマーカー表示
        //ログイン済みかどうかを確認
        if Auth.auth().currentUser != nil {
            
            //listenerを登録して投稿データの更新を監視する
            let postRef = Firestore.firestore().collection(Const.PostPath).order(by: "date", descending: true)
            //addSnapshotListenerメソッドがpostrefで取得する投稿データを監視し、投稿データが追加される・更新される度にクロージャ内の処理が呼び出される
            listener = postRef.addSnapshotListener() {(querySnapshot,error) in  //querySnapshotに最新の投稿データが入っている。
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
        
    }
    
    //ホーム画面を閉じる時
    override func viewWillDisappear(_ animated: Bool) {
        //listenerを削除して監視を停止する
        listener?.remove()
    }
    
    
    //現在地が更新されたら呼び出す→アプリ起動時に現在地を初期表示とするために処理
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = locations.last
        
        let camera = GMSCameraPosition.camera(withLatitude: userLocation!.coordinate.latitude, longitude: userLocation!.coordinate.longitude, zoom: 17.0)
        
        self.mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
    
    //PostDataクラスから投稿データの緯度・経度を引っ張って、マーカーを表示させる
    func makeMarker(postData: PostData) {
        //投稿データがあるか否かで場合分け＊↓この場合分けがないと起動したホーム画面で止まってしまう。
        if postData.latitude == nil || postData.longitude == nil {
            //ないならこのメソッドの処理はしなくていいから出よう
            return
        }else {
            //投稿がある場合
        //PostDataクラスの緯度・経度
        lati = postData.latitude!
        longi = postData.longitude!
        
        //地図上に投稿データの数だけマーカーを表示させる
        let marker: GMSMarker = GMSMarker()
        marker.position = CLLocationCoordinate2D(latitude: lati, longitude: longi)
        marker.userData = postData  //マーカーに投稿データ情報をのせておく
        marker.map = mapView  //マップ上に表示
        markers.append(marker)  //新たなマーカーとしてを配列に追加
        }
    }
    
    //マーカーをタップしたら該当の投稿データ閲覧画面にモーダル遷移（ShowViewController）
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        //投稿情報を載せたマーカーを遷移するときはPostDataとして渡す
        let postData = marker.userData as! PostData
        //遷移先を取得して、情報を渡して遷移処理
        let showViewController = storyboard!.instantiateViewController(withIdentifier: "Show") as! ShowViewController
        showViewController.postData = postData
        present(showViewController, animated: true, completion: nil)
        
        return false  //吹き出しの代わりに画面遷移と値渡しするからfalse
    }
    
//    //画面表示領域のみマーカーを表示（データ処理が重くなるのを軽減）→削除したマーカーが出現するのを防ぐため一旦機能停止
//    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
//        for marker in markers {
//            if mapView.projection.contains(marker.position) {
//                marker.map = mapView
//            }else {
//                marker.map = nil
//            }
//        }
//    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
