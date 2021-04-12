//
//  AgreeViewController.swift
//  TouringspotShareApp
//
//  Created by 白井淳 on 2021/03/25.
//

import UIKit
import SVProgressHUD

class AgreeViewController: UIViewController {
    
    @IBOutlet weak var checkButton: UIButton!
    
    let checkedImage = UIImage(named: "check_on")
    let uncheckedImage = UIImage(named: "check_off")
    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.checkButton.setImage(uncheckedImage, for: .normal)
        self.checkButton.setImage(checkedImage, for: .selected)
    }
    
    //チェックボタンにタップしたら状態が反転する処理＊このときUIButtonの設定はCustum、TextColorは黒、Imageにチェックオフを設定しよう。
    @IBAction func checkButtonTap(_ sender: Any) {
        self.checkButton.isSelected = !self.checkButton.isSelected
    }
    
    @IBAction func StartButton(_ sender: Any) {
        guard (self.checkButton.isSelected) else {
            print("チェック入れて")
            SVProgressHUD.showError(withStatus: "「利用規約に同意します。」にチェックを入れてください。")
            SVProgressHUD.dismiss(withDelay: 1)
            return
        }
        print("利用開始")
        //タブ画面に戻る（一気に先頭画面に戻る）
        UIApplication.shared.windows.first{ $0.isKeyWindow }?.rootViewController?.dismiss(animated: true, completion: nil)
    }
    
    //利用規約画面から戻る処理
    @IBAction func termsButton(_ sender: UIStoryboardSegue) {
    }
    
    //プライバシーポリシー画面から戻る処理
    @IBAction func privacyButton(_ sender: UIStoryboardSegue) {
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
