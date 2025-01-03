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
        // Put setup code here. This method is called before the invocation of each test method in the class.
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
                    $0.authClient = .testValue
                }
            )
        )
        let vc = UIHostingController(rootView: view)
        vc.view.frame = UIScreen.main.bounds
        assertSnapshot(of: vc, as: .image(on: .iPhoneSe))
        assertSnapshot(of: vc, as: .image(on: .iPhone13))
        assertSnapshot(of: vc, as: .image(on: .iPhone13Mini))
        assertSnapshot(of: vc, as: .image(on: .iPhone13Pro))
        assertSnapshot(of: vc, as: .image(on: .iPhone13ProMax))
    }
}
