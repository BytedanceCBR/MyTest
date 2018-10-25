//
//  AddressBookSync.swift
//  Article
//
//  Created by leo on 2018/8/31.
//

import Foundation
class AddressBookSync {
    class func trySyncAddressBook() {
        DispatchQueue.global().async {
            TTAddressBookService.shared().loadAllContacts(start: {

            }) { (contacts, error) in
                if error == nil {
                    TTContactsNetworkManager.post(
                        contacts,
                        source: TTContactsUploadSourceSilent,
                        userActive: false,
                        completion: { (error, jsonObj) in
                    print("通讯录同步完成\(error) - \(jsonObj)")
                    })
                } else {
                    assertionFailure()
                }
            }
        }
    }
}
