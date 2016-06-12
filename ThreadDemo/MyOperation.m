//
//  MyOperation.m
//  ThreadDemo
//
//  Created by 向海涛 on 16/3/31.
//  Copyright © 2016年 xiang. All rights reserved.
//

#import "MyOperation.h"

@implementation MyOperation

- (void)main {
  @autoreleasepool {
    NSLog(@"myoperation-----------");
    NSThread *currentThread = [NSThread currentThread];
    [currentThread setName:@"MyOperation"];
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    [runLoop addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
    NSTimer *timer = [NSTimer timerWithTimeInterval:1.0
                                             target:self
                                           selector:@selector(test)
                                           userInfo:nil
                                            repeats:YES];
    [runLoop addTimer:timer forMode:NSDefaultRunLoopMode];

    NSLog(@"%@", runLoop);
    [runLoop run];
  }
}

- (void)test {
  NSLog(@"myOperation test");
}

@end
