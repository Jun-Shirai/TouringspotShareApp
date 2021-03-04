//
//  TabBarController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/02/26.
//

import UIKit
import Firebase

class TabBarController: UITabBarController,UITabBarControllerDelegate {
    
    //起動時にログイン状態を確認する
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //ログインしていない場合
        if Auth.auth().currentUser == nil {
            //LoginViewControllerを取得して遷移する（今回はモーダル遷移）
            let loginViewCotroller = self.storyboard?.instantiateViewController(withIdentifier: "Login")
            self.present(loginViewCotroller!, animated: true, completion: nil)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        // タブアイコンの色
        self.tabBar.tintColor = UIColor(red: 1.0, green: 0.44, blue: 0.11, alpha: 1)
        // タブバーの背景色
        self.tabBar.barTintColor = UIColor(red: 0.96, green: 0.91, blue: 0.87, alpha: 1)
        // UITabBarControllerDelegateプロトコルのメソッドをこのクラスで処理する。
        self.delegate = self
        
    }
    
    // タブバーのアイコンがタップされた時に呼ばれるdelegateメソッドを処理する。
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if viewController is ImageSelectViewController {
            // ImageSelectViewControllerは、タブ切り替えではなくモーダル画面遷移する
            let imageSelectViewController = storyboard!.instantiateViewController(withIdentifier: "ImageSelect")
            present(imageSelectViewController, animated: true)
            return false
        } else {
            // その他のViewControllerは通常のタブ切り替えを実施
            return true
        }
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
