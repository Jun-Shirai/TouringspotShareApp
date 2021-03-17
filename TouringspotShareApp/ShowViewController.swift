//
//  ShowViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/03/03.
//

import UIKit
import Firebase
import FirebaseUI  //Firebaseから画像を持ってくるためのプロパティやメソッドを使用するためにインポート

class ShowViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    //タップされたマーカー（位置情報）から投稿データをうけとる変数の設定
    var postData: PostData!
    
    var listener: ListenerRegistration?  //Firestoreのリスナー
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        //Firebase内の投稿データを取得。該当の投稿データを取得するため、「.document(postData.id)」で指定
        let postsRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
        //addSnapshotListenerで新しいデータが追加更新される旅に監視し、以下の処理を施す。
        listener = postsRef.addSnapshotListener() {(querySnapshot,error)in
            
            guard let document = querySnapshot else {
                print("データ取得に失敗しました。\(error!)")
                return
            }
            guard let data = document.data() else {
                print("データがありません。")
                return
            }
            print("データが更新されました。\(data)")
            //↓let postDataではなくself.postDataにしよう。let~で宣言すると、ローカル変数のため、一度処理（この場合は更新）されると消えることになる。それだといいねボタンを２回目にタップした際、Firebaseに更新はされているが、画面表示の更新はされなくなり、（ShowViewControllerを）開き直さないと更新されない状態になってしまう。
            self.postData = PostData(document: querySnapshot! as DocumentSnapshot)  //最新データをPostDataクラスのイニシャライザにあたはめて更新。
            self.setPostData(self.postData)  //投稿データを画面に反映させる
        }
        
        
    }
    
    //画像はFirebaseより、画像以外の投稿データはPostDataから引っ張ってきくる
    func setPostData(_ postData: PostData) {
        
        //画像の表示
        //import FirebaseUIによってsd_imageIndicatorプロパティやsd_setImageメソッドを使用できる
        postImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        //↑DL中のインジケーターを表示
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postData.id + ".jpg")
        postImageView.sd_setImage(with: imageRef)  //UIImageViewに取得した画像をはりつける
        
        //キャプションの表示
        self.captionLabel.text = "\(postData.name!) : \(postData.caption!)"
        
        
        //日時の表示
        self.dateLabel.text = ""
        if let date = postData.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm"
            let  dateString = formatter.string(from: date)
            self.dateLabel.text = dateString
            
        }
        //いいね数の表示
        let likeNumber = postData.likes.count
        likeLabel.text = "\(likeNumber)"
        
        //いいねボタンの表示
        if postData.isLiked {
            //いいねしてるときの表示
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        }else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
    
    //いいねボタンがタップされたときの処理
    @IBAction func likeTapButton(_ sender: Any) {
        print("いいねおされたよ")
        //いいねをIDとして定義
        if let myid = Auth.auth().currentUser?.uid {
            //Firebaseにて更新する（updateDataメソッド）ときにつかうために用意
            var updataValue: FieldValue
            //いいねしてる・してないの場合分け
            if postData.isLiked {
                //してるときにタップしたら、いいねを取り除く
                updataValue = FieldValue.arrayRemove([myid])
            }else {
                //してないときにタップしたらいいねを追加
                updataValue = FieldValue.arrayUnion([myid])
            }
            //タップ処理したことをFirebaseにて更新・保存処理
            let postRef = Firestore.firestore().collection(Const.PostPath).document(postData.id)
            postRef.updateData(["likes" : updataValue])
        }
        
    }
    
    //閉じるボタン
    @IBAction func returnButton(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    //投稿データの削除機能。ログインユーザー名と投稿者名が同じ時に削除できるよう場合分けで記述。
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
