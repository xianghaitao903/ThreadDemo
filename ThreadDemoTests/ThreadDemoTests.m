//
//  ThreadDemoTests.m
//  ThreadDemoTests
//
//  Created by 向海涛 on 16/3/29.
//  Copyright © 2016年 xiang. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "User.h"

@interface ThreadDemoTests : XCTestCase

@end

@implementation ThreadDemoTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testUser {
    dispatch_queue_t queue = dispatch_queue_create("text.user.queue", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_async(queue, ^{
        User *user = [User sharedUser];
        [user addObject:[NSNumber numberWithInt:0]];
        NSLog(@"test1 %lu",(unsigned long)user.array.count);
    });
    
    dispatch_async(queue, ^{
        User *user = [User sharedUser];
        for (int i = 5; i < 10; i ++) {
            [user addObject:[NSNumber numberWithInt:i]];
            NSLog(@"%d",i);
        }
        NSLog(@"test2 %lu",(unsigned long)user.array.count);
    });
    
    dispatch_async(queue, ^{
        User *user = [User sharedUser];
        for (int i = 10; i < 15; i ++) {
            [user addObject:[NSNumber numberWithInt:i]];
            NSLog(@"%d",i);
        }
        NSLog(@"test3 %lu",(unsigned long)user.array.count);
    });
    
    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
