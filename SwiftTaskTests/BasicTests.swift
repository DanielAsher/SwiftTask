//
//  BasicTests.swift
//  SwiftTask
//
//  Created by Yasuhiro Inami on 2014/08/27.
//  Copyright (c) 2014年 Yasuhiro Inami. All rights reserved.
//

import SwiftTask
import XCTest

class BasicTests: _TestCase
{
    func testExample()
    {
        typealias Task = SwiftTask.Task<Float, String, ErrorString>
        
        var expect = self.expectationWithDescription(__FUNCTION__)
        var progressCount = 0
        
        // define task
        let task = Task { progress, fulfill, reject, configure in
            
            Async.main(after: 0.1) {
                progress(0.0)
                progress(1.0)
                
                if arc4random_uniform(2) == 0 {
                    fulfill("OK")
                }
                else {
                    reject("ERROR")
                }
            }
            return
            
        }
        
        task.progress { oldProgress, newProgress in
            
            println("progress = \(newProgress)")
            
        }.success { value -> String in  // `task.success {...}` = JavaScript's `promise.then(onFulfilled)`
            
            XCTAssertEqual(value, "OK")
            return "Now OK"
            
        }.failure { error, isCancelled -> String in  // `task.failure {...}` = JavaScript's `promise.catch(onRejected)`
            
            XCTAssertEqual(error!, "ERROR")
            return "Now RECOVERED"
            
        }.then { value, errorInfo -> Task in // `task.then {...}` = JavaScript's `promise.then(onFulfilled, onRejected)`
            
            println("value = \(value)") // either "Now OK" or "Now RECOVERED"
            
            XCTAssertTrue(value!.hasPrefix("Now"))
            XCTAssertTrue(errorInfo == nil)
            
            return Task(error: "ABORT")
            
        }.then { value, errorInfo -> Void in
                
            println("errorInfo = \(errorInfo)")
            
            XCTAssertTrue(value == nil)
            XCTAssertEqual(errorInfo!.error!, "ABORT")
            expect.fulfill()
                
        }
        
        self.wait()
    }

}