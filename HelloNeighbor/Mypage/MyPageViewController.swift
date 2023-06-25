//
//  MyPageViewController.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/06/15.
//

import UIKit
import Nuke
import Firebase
import PKHUD
import SCLAlertView_Objective_C

class MyPageViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    var user:User!
    @IBOutlet weak var profileImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageView.layer.cornerRadius = 40
        profileImageView.isUserInteractionEnabled = true
        let tapNarrowGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(openCamera))
        profileImageView.addGestureRecognizer(tapNarrowGestureRecognizer)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        fetchMyInfo()
    }
    
    private func fetchMyInfo(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).getDocument {(snapshot, err ) in
            if let err = err{
                print("ログインユーザーの取得に失敗しました。\(err)")
                return
            }
            let dic = snapshot?.data()
            self.user = User.init(dic: dic!)
            if let url = URL(string: self.user.userImageUrl){
                Nuke.loadImage(with: url, into: self.profileImageView)
            }
        }
    }
    
    @objc func openCamera(gestureRecognizer: UITapGestureRecognizer) {
        self.view.endEditing(true)
        let alert = SCLAlertView()
        alert.addButton("アルバムを開く", actionBlock: {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        })
        alert.addButton("カメラを開く", actionBlock: {
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.allowsEditing = true
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        })
        alert.showSuccess(self, title: "プロフィール画像を設定", subTitle: nil, closeButtonTitle: "キャンセル", duration: 0)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let editImage = info[.editedImage] as? UIImage {
            profileImageView.image = editImage
        }else if let originalImage = info[.originalImage] as? UIImage{
            profileImageView.image = originalImage
        }
        dismiss(animated:true, completion: nil)
        updateProfileImage()
    }
    
    func updateProfileImage(){
        HUD.show(.progress)
        let profileImage = profileImageView.image ?? UIImage(named: "noImage")
        guard let uploadProfileImage = profileImage?.jpegData(compressionQuality: 0.5) else {return}
        let fileName = NSUUID().uuidString
        let storageRef = Storage.storage().reference().child("profie_image").child(fileName)
        storageRef.putData(uploadProfileImage, metadata: nil) { (metadata, err) in
            if let err = err {
                print("Firebaseへの画像の保存に失敗しました。\(err)")
                HUD.hide()
                return
            }
            storageRef.downloadURL { (url, err) in
                if let err = err{
                    print("Firebaseからのダウンロードに失敗しました。\(err)")
                    HUD.hide()
                    return
                }
                guard let userImageUrl = url?.absoluteString else {return}
                guard let uid = Auth.auth().currentUser?.uid else {return}
                Firestore.firestore().collection("users").document(uid).updateData([
                    "userImageUrl": userImageUrl,
                ]) { err in
                    if let err = err {
                        HUD.hide()
                        print("情報を更新できませんでした。: \(err)")
                        return
                    }
                    HUD.hide()
                }
            }
        }
    }
    
    
}
