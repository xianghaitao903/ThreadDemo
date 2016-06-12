//
//  User.h
//  ThreadDemo
//
//  Created by 向海涛 on 16/4/7.
//  Copyright © 2016年 xiang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface User : NSObject

+(instancetype)sharedUser;

- (void)addObject:(NSObject *)item;

- (NSArray *)array;

@end
