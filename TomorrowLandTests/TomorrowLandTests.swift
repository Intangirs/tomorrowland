//
//  TomorrowLandTests.swift
//  TomorrowLandTests
//
//  Created by Yusuke Ohashi on 2018/08/17.
//  Copyright © 2018 Yusuke Ohashi. All rights reserved.
//

import XCTest
@testable import TomorrowLand

class TomorrowLandTests: XCTestCase {

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
//        let document = Document(source: "<p>test<br>test2<br></p>")
//        print(document)
//        XCTAssertTrue(document.entities.count == 1)
//        XCTAssertTrue(document.entities[0].name == "p")
//
//        let document2 = Document(source: "<p>test<br>test2<br><span>testspan</span></p>")
//        print(document2)
//        XCTAssertTrue(document2.entities.count == 1)
//        XCTAssertTrue(document2.entities[0].name == "p")

        let document3 = Document(source: "<p>test<br>test2<br><span><span>test</span>span</span></p>")
        print(document3)
        XCTAssertTrue(document3.entities.count == 1)
        XCTAssertTrue(document3.entities[0].name == "p")
    }

    func testStripHTML() {
        let stripped = "<p><span class=\"h-card\"><a href=\"https://mstdn.guru/@drikin\" class=\"u-url mention\" rel=\"nofollow noopener\" target=\"_blank\">@<span>drikin</span></a></span> 付き合いたてのラブラブのカップルのようですね😍</p>".stripHTML()
        print(stripped)
    }

    func testStrip2() {
        let stripped = "<p>実はオフ会からまだ帰宅していない(^_^;)<br>ココで例のアレ見てから帰ります。<br><a href=\"https://mstdn.guru/tags/%E9%96%8B%E5%BA%97%E9%81%85%E3%81%84\" class=\"mention hashtag\" rel=\"nofollow noopener\" target=\"_blank\">#<span>開店遅い</span></a>！11時 <a href=\"https://mstdn.guru/media/AWs7-fpdeIWC8T2TCVo\" rel=\"nofollow noopener\" target=\"_blank\"><span class=\"invisible\">https://</span><span class=\"ellipsis\">mstdn.guru/media/AWs7-fpdeIWC8</span><span class=\"invisible\">T2TCVo</span></a></p>".stripHTML()
        print(stripped)
    }

    func testStrip3() {
        let stripped = "<p><span class=\"h-card\"><a href=\"https://mstdn.guru/@drikin\" class=\"u-url mention\" rel=\"nofollow noopener\" target=\"_blank\">@<span>drikin</span></a></span> 付き合いたてのラブラブのカップルのようですね😍</p>".stripHTML()
        print(stripped)
    }

    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }

}
