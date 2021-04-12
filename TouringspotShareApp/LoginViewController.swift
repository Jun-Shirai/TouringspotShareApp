//
//  LoginViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/02/26.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginViewController: UIViewController {
    
    @IBOutlet weak var mailAddressTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var displayNameTextField: UITextField!
    
    //ログインボタンがタップされた時のメソッド呼び出し
    @IBAction func loginButton(_ sender: Any) {
        if let address = mailAddressTextField.text,
           let password = passwordTextField.text {
            
            //アドレスとパスワード名のいずれかでも入力されていない時は何もない
            if address.isEmpty || password.isEmpty {
                
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                SVProgressHUD.dismiss(withDelay: 1)
                return
            }
            
            //HUDで処理中を表示
            SVProgressHUD.show()  //←グルグルマークでロード中の表示が出る
            
            //ログイン成功
            Auth.auth().signIn(withEmail: address, password: password) {authResult, error in  //このerrorを確認してログイン成功かどうかの判断をする処理になっている。
                
                if let error = error {
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    
                    SVProgressHUD.showError(withStatus: "サインインに失敗しました。")
                    return
                }
                print("DEBUG_PRINT: ログインに成功しました。")
                
                //HUDを消す
                SVProgressHUD.dismiss()
                
                //画面を閉じてタブ画面に戻る
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    //アカウント作成ボタンがタップされた時に呼び出すメソッド
    @IBAction func createAccountButton(_ sender: Any) {
        if let address = mailAddressTextField.text,
           let password = passwordTextField.text,
           let displayName = displayNameTextField.text {
            
            //アドレスとパスワードと表示名のいずれかでも入力されていない時は何もしない
            if address.isEmpty || password.isEmpty || displayName.isEmpty {
                print("DEBUG_PRINT: 何かが空文字です。")
                
                SVProgressHUD.showError(withStatus: "必要項目を入力して下さい")
                SVProgressHUD.dismiss(withDelay: 1)
                return
            }
            
            //HUDで処理中を表示中
            SVProgressHUD.show()
            
            //アドレスとパスワードでユーザー作成。ユーザー作成に成功すると、自動的にログインする。
            Auth.auth().createUser(withEmail: address, password: password) {authResult, error in  //このerrorを確認してアカウント作成が成功したかどうか判断する処理になっている。
                
                if let error = error {
                    
                    //エラーがあったら原因をプリントして、リターンすることで以降の処理を実行せずに処理を終了する
                    print("DEBUG_PRINT: " + error.localizedDescription)
                    //↑Firebaseという外部サービス側でエラーが起こった時、localizedDescriptionでStringをとりだしてプリントする
                    
                    SVProgressHUD.showError(withStatus: "ユーザー作成に失敗しました。")
                    
                    return
                }
                print("DEBUG_PRINT: ユーザー作成に成功しました。")
                
                //表示名を設定する
                let user = Auth.auth().currentUser
                if let user = user {
                    let changeRequest = user.createProfileChangeRequest()
                    changeRequest.displayName = displayName
                    changeRequest.commitChanges {error in
                        if let error = error {
                            //プロフィールの更新でエラーが発生
                            print("DEBUG_PRINT: " + error.localizedDescription)
                            return
                        }
                        print("DEBUG_PRINT: [displayName = \(user.displayName!)]の設定に成功しました。")
                        
                        //HUDを消す
                        SVProgressHUD.dismiss()
                        
                        //利用規約同意画面に遷移
                        self.performSegue(withIdentifier: "toAgree", sender: self)
                    }
                    
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        //各テキストの設定
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.lightGray
        ]
        mailAddressTextField.attributedPlaceholder = NSAttributedString(string: "メールアドレス", attributes: attributes)  //プレイスホルダー
        mailAddressTextField.textColor = UIColor.black  //テキストの色
        mailAddressTextField.backgroundColor = UIColor.white  //テキスト背景色
        passwordTextField.attributedPlaceholder = NSAttributedString(string: "パスワード６文字以上", attributes: attributes)
        passwordTextField.textColor = UIColor.black
        passwordTextField.backgroundColor = UIColor.white
        displayNameTextField.attributedPlaceholder = NSAttributedString(string: "アカウント作成時は表示名を入力", attributes: attributes)
        displayNameTextField.textColor = UIColor.black
        displayNameTextField.backgroundColor = UIColor.white
        
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
