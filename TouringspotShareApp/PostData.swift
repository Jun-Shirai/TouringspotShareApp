//
//  PostData.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/03/02.
//

import UIKit
import Firebase

class PostData: NSObject {
var id: String  //投稿者ID、保存のために作成　＊String?にならない理由としては、下記イニシャライザにて id != nil（nilは絶対に入らない）の初期化宣言をしているため。
    var name: String?  //投稿者名　＊nilが入る可能性も考えて?をつけている
    var caption: String?  //キャプション：投稿者名と投稿者からのコメント　＊nilが入る可能性も考えて?をつけている
    var latitude: Double?
    var longitude: Double?
    var date: Date?  //日時　　＊nilが入る可能性も考えて?をつけている
    var likes: [String] = []  //複数のいいねした人のID（文字列）を扱うため、配列型にする
    var isLiked: Bool = false  //自分がいいねしたかどうかのフラグ
    
    
    //イニシャライザ　＊上記プロパティのままだとデフォルト（初期）値がなく、変数の使い方がわからないため
    init(document: DocumentSnapshot) {  //ShowViewControllerにてデータ更新する際に扱うquerySnapshot（最新データが含まれている）がDocumentSnapshot型のため、QueryDocumentSnapshot→DocumentSnapshotに変更
        self.id = document.documentID
        let postDic = document.data()!  //DocumentSnapshotへの変更に伴い、「！」を追記
        self.name = postDic["name"] as? String
        self.caption = postDic["caption"] as? String
        self.latitude = postDic["latitude"] as? Double
        self.longitude = postDic["longitude"] as? Double
        let timestamp = postDic["date"] as? Timestamp
        self.date = timestamp?.dateValue()
        
        //nilがくる可能性もあるので、そのうちString型の場合に限って、下記デフォルト値に代入して扱うという意味
        if let likes = postDic["likes"] as? [String] {
            self.likes = likes
        }
        if let myid = Auth.auth().currentUser?.uid {
            //likesの配列の中にmyidが含まれているかチェックすることで、自分が「いいね」を押しているかを判断
            if self.likes.firstIndex(of: myid) != nil {
                //myidがあれば、「いいね」を押していると認識する
                self.isLiked = true
            }
        }
    }
}

