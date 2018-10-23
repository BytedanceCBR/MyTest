//
//  AddressBookSync.swift
//  Article
//
//  Created by leo on 2018/8/31.
//

import Foundation
class AddressBookSync {
    class func trySyncAddressBook() {
        TTAddressBookService.shared().loadAllContacts(start: {

        }) { (contacts, error) in

        }
    }
}
