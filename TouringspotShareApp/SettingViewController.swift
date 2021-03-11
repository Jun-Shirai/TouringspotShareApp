//
//  SettingViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/02/26.
//

import UIKit
import Firebase
import SVProgressHUD

class SettingViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!  //バイクアイコン
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //アカウント名変更ボタンがタップされたときに呼び出すメソッド
    @IBAction func changeButton(_ sender: Any) {
        if let displayName = displayNameTextField.text {
            
            //
            if displayName.isEmpty {
                SVProgressHUD.showError(withStatus: "表示名を入力して下さい")
                SVProgressHUD.dismiss(withDelay: 1)
                return
            }
            
            //
            let user = Auth.auth().currentUser
            
            if let user = user {
                let changeReqest = user.createProfileChangeRequest()
                changeReqest.displayName = displayName
                changeReqest.commitChanges {error in
                    if let error = error {
                        
                        SVProgressHUD.showError(withStatus: "表示名の変更に失敗しました。")
                        print("DEBUG_PRINT: " + error.localizedDescription)
                        return
                    }
                    print("DEBBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                    
                    //HUDで完了を知らせる
                    SVProgressHUD.showSuccess(withStatus: "表示名を変更しました")
                    SVProgressHUD.dismiss(withDelay: 1)
                    
                }
            }
        }
        //キーボードを閉じる
        self.view.endEditing(true)
    }
    
    //ログアウトボタンがタップされたときに呼び出すメソッド
    @IBAction func logoutButton(_ sender: Any) {
        //ログアウトする
        try!Auth.auth().signOut()
        
        //ログイン画面を表示する
        let loginViewController = self.storyboard?.instantiateViewController(withIdentifier: "Login")
        self.present(loginViewController!, animated: true, completion: nil)
        
        //ログイン画面から戻ってきた時にホーム画面へ切り替えるよう処理する（index = 0）
        tabBarController?.selectedIndex = 0
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //バイクアイコンを追加
        let image = UIImage(named: "bike")
        imageView.image = image

        //この設定画面を開く度に現在ログインしているアカウント名を取得してTextFieldに反映する（を更新する）
        let user = Auth.auth().currentUser
        if let user = user {
            displayNameTextField.text = user.displayName
        }
        
        //テキストの設定
        displayNameTextField.textColor = UIColor.black  //テキストの色
        displayNameTextField.backgroundColor = UIColor.white  //テキスト背景色
        
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
