//
//  PostViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/02/27.
//

import UIKit
import Firebase
import SVProgressHUD

class PostViewController: UIViewController {
    
    var image: UIImage!  //画像を受け取るために
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    
    //位置情報選択画面から戻る時に使用
    @IBAction func positionUnwind(_ sender: UIStoryboardSegue) {
    }
    
    //投稿ボタンがタップされたとき
    @IBAction func postButton(_ sender: Any) {
        
        //画像をjpeg形式に変換する
        let imageData = image.jpegData(compressionQuality: 0.75)
        
        //画像と投稿データの保存場所を定義
        let postRef = Firestore.firestore().collection(Const.PostPath).document()
        let imageRef = Storage.storage().reference().child(Const.ImagePath).child(postRef.documentID + ".jpg")
        
        //HUDで投稿処理中の表示を開始
        SVProgressHUD.show()
        
        //Storageに画像をアップロードする
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        imageRef.putData(imageData!,metadata: metadata) {(metadata,error) in
            if error != nil {
                //error = nilのとき、「エラーがない＝処理が成功」ということだから、その反対で「エラーが何かしらある」表現を上記で記述してerror != nilになる。
                
                //画像のアップロード失敗
                print(error!)
                SVProgressHUD.showError(withStatus: "画像のアップロードが失敗しました")
                
                //投稿処理をキャンセルし、先頭画面に戻る。＊UIApplication~nil)のコードを使用することで先頭画面まで一気に戻ることが可能
                UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
                return
            }
            //FireStoreに投稿データを保存する
            let name = Auth.auth().currentUser?.displayName
            let postDic = [
                "name": name!,
                "caption": self.textField.text!,
                "latitude": self.latitudeTextField.text!,  //緯度
                "longitude": self.longitudeTextField.text!,  //経度
                "date": FieldValue.serverTimestamp(),
            ] as [String: Any]
            postRef.setData(postDic)
            
            //HUDで投稿完了を表示する
            SVProgressHUD.showSuccess(withStatus: "投稿しました")
            
            //投稿処理が完了したので先頭画面に戻る
            UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
        }
    }
    
    //キャンセルボタンがタップされたとき
    @IBAction func cancelButton(_ sender: Any) {
        //加工画面に戻る。＊self.dismissで一つ前の画面に戻る
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        imageView.image = image  //画像を表示
    }
    
    //textField以外の部分をタッチしてキーボードを閉じる
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
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
