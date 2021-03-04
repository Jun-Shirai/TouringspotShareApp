//
//  ShowViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/03/03.
//

import UIKit
import FirebaseUI  //Firebaseから画像を持ってくるためのプロパティやメソッドを使用するためにインポート

class ShowViewController: UIViewController {
    
    @IBOutlet weak var postImageView: UIImageView!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var likeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var captionLabel: UILabel!
    
    //タップされたマーカー（位置情報）から投稿データをうけとる変数の設定
    var postData: PostData!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    //画像はFirebaseより、画像以外の投稿データはPostDataから引っ張ってくる
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
            let buttonImage = UIImage(named: "like_exist")
            self.likeButton.setImage(buttonImage, for: .normal)
        }else {
            let buttonImage = UIImage(named: "like_none")
            self.likeButton.setImage(buttonImage, for: .normal)
        }
    }
    
    //いいねボタンがタップされたときの処理
    @IBAction func likeTapButton(_ sender: Any) {
        
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
