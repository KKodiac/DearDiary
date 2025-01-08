//
//  AccountSnapshot.swift
//  AccountTest
//
//  Created by Sean Hong on 1/1/25.
//

import ComposableArchitecture
import SnapshotTesting
import XCTest
import SwiftUI

@testable import Account


final class AccountSnapshot: XCTestCase {
    
    override func setUpWithError() throws {
        // isRecording = true
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAccountSnapshot() throws {
        let view = AccountView(
            store: StoreOf<Account>(
                initialState: Account.State(),
                reducer: { Account() },
                withDependencies: {
                    $0.authClient = .snapshotValue
                }
            )
        )
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshots(
            of: vc,
            as: [
                .image(on: .iPhoneSe),
                .image(on: .iPhone13),
                .image(on: .iPhone13Mini),
                .image(on: .iPhone13Pro),
                .image(on: .iPhone13ProMax),
            ]
        )
    }
}
