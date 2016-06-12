//
//  User.m
//  ThreadDemo
//
//  Created by 向海涛 on 16/4/7.
//  Copyright © 2016年 xiang. All rights reserved.
//

#import "User.h"
@interface User()

@property (nonatomic, strong, readonly) NSMutableArray *arr;
@property (nonatomic, strong) dispatch_queue_t currentQueue;

@end

@implementation User

+ (instancetype)sharedUser {
    static User *sharedUser = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,^{
        sharedUser = [[User alloc] init];
        sharedUser -> _arr = [NSMutableArray array];
        sharedUser.currentQueue = dispatch_queue_create("com.shareUser.arr", DISPATCH_QUEUE_CONCURRENT);
    });
    return sharedUser;
}

- (void)addObject:(NSObject *)item {
    
    dispatch_barrier_async(self.currentQueue, ^{
       [_arr addObject:item];
    });
}

- (NSArray *)array {
    __block NSArray *arr ;
    dispatch_sync(self.currentQueue, ^{
        arr = [NSArray arrayWithArray:_arr];
    });
    return arr;
}

@end
