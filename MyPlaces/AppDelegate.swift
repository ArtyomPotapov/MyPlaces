//
//  AppDelegate.swift
//  MyPlaces
//
//  Created by Artyom Potapov on 11.07.2022.
//

import UIKit
import RealmSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
// MARK: - тут вставлен кусок кода из видео 21.Sorting 5-го модуля (время 3:40), там автор копировал его со старой версии сайта Realm.io в разделе миграции, но теперь там всё не так, а где брать его сейчас я не знаю, ибо этот сайт частично с ошибкой 403. Всё это нужно при изменении модели (добавление какого-то нового поля, как в нашем случае свойство "date") после того, как уже создана какая-то база в программе и надо внести в неё изменения без сноса базы или без переустановки программы.
       
        let schemaVersion: UInt64 = 2
        
        let config = Realm.Configuration(schemaVersion: schemaVersion,
                                         migrationBlock: {migration, oldSchemaVersion in
            if (oldSchemaVersion < schemaVersion){
                //nothing to do!
                // умный Realm сам всё поймёт и проглотит то новое свойтво, которого раньше не было
            }
        })
        
        Realm.Configuration.defaultConfiguration = config
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }


}

