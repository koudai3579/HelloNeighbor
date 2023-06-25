//
//  AppDelegate.swift
//  HelloNeighbor
//
//  Created by Koudai Okamura on 2023/05/31.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        updateLastLoginTime()
        sleep(1)
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
    
    //ログイン済ユーザ→最終ログインを更新
    private func updateLastLoginTime(){
        guard let uid = Auth.auth().currentUser?.uid else {return}
        Firestore.firestore().collection("users").document(uid).updateData([
            "lastLogin": Timestamp(),
        ]) { err in
            if let err = err {
                print("情報を更新できませんでした。: \(err)")
            }
        }
    }


}

