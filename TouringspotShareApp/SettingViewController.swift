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
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
    
    //利用規約画面から戻る処理
    @IBAction func retermsButton(_ sender: UIStoryboardSegue) {
    }
    
    //プライバシーポリシー画面から戻る処理
    @IBAction func reprivacyButton(_ sender: UIStoryboardSegue) {
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
