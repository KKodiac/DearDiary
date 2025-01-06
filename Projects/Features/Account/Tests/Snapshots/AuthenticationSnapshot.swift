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


final class AuthenticationSnapshot: XCTestCase {
    
    override func setUpWithError() throws {
        // isRecording = true
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testAuthenticationSnapshot() throws {
        let view = AuthenticationScreen(
            store: StoreOf<Authentication>(
                initialState: Authentication.State(
                    clientUID: Shared("")
                ),
                reducer: { Authentication() },
                withDependencies: {
                    $0.authClient = .snapshotValue
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
