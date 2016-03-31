//
//  ViewController.m
//  ThreadDemo
//
//  Created by 向海涛 on 16/3/29.
//  Copyright © 2016年 xiang. All rights reserved.
//

#import "ViewController.h"
static NSString *kURL = @"http://127.0.0.1:8020/GangFuTong/img/checkfocus1@2x.png";
@interface ViewController ()
{
    NSLock *theLock;
    NSCondition *theCondition;
    NSThread *threadOne;
    NSThread *threadTwo;
    NSThread *threadThree;
    NSInteger tickets;
    NSInteger count;
}
@end

@implementation ViewController

#pragma mark - lifeCycle
- (void)viewDidLoad {
    [super viewDidLoad];
//    [self addLockAndCondition];
//    [self operationsTest];
//    [self testGroupAsync];
    [self testBarrierAsync];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - NSThread
- (void)threadStart2 {
    [NSThread detachNewThreadSelector:@selector(downloadImage:)
                             toTarget:self
                           withObject:kURL];
}
- (void)threadStart {
    NSThread *thread = [[NSThread alloc] initWithTarget:self
                                               selector:@selector(downloadImage:)
                                                 object:kURL];
    [thread start];
}

#pragma mark - 下载图片
- (void)downloadImage:(NSString *)kurl {
    NSData *data = [[NSData alloc] initWithContentsOfURL:
                    [NSURL URLWithString:kurl]];
    UIImage *image = [[UIImage alloc]initWithData:data];
    if(image == nil){
        
    }else{
        [self performSelectorOnMainThread:@selector(updateUI:)
                               withObject:image
                            waitUntilDone:YES];
    }
}
#pragma mark 更新UI
- (void)updateUI:(UIImage*) image{
    self.imageView.image = image;
}

#pragma mark - NSLock and condition
- (void)addLockAndCondition {
    tickets = 100;
    count = 0;
    theLock = [[NSLock alloc] init];
    theCondition = [[NSCondition alloc] init];
    
    threadOne = [[NSThread alloc] initWithTarget:self
                                        selector:@selector(run)
                                          object:nil];
    [threadOne setName:@"Thread-1"];
    [threadOne start];
    
    threadTwo = [[NSThread alloc] initWithTarget:self
                                        selector:@selector(run)
                                          object:nil];
    [threadTwo setName:@"Thread-2"];
    [threadTwo start];
    
    threadThree = [[NSThread alloc] initWithTarget:self
                                          selector:@selector(run3)
                                            object:nil];
    [threadThree setName:@"Thread-3"];
    [threadThree start];
}

- (void)run3 {
    while (YES) {
        [theCondition lock];
        [NSThread sleepForTimeInterval:3];
        [theCondition signal];
        [theCondition unlock];
    }
}

- (void)run{
    while (TRUE) {
        [theCondition lock];
        [theCondition wait];
        [theLock lock];
        if (tickets > 0) {
            tickets = tickets - 1;
            count += 1;
            NSString *threadName = [[NSThread currentThread] name];
            NSLog(@"执行了%ld次，还剩下%ld张票,线程名：%@",(long)count,(long)tickets,threadName);
        } else {
            break;
        }
        [theCondition unlock];
        [theLock unlock];
    }
}

- (void)lockSynchronized {
    @synchronized (nil) {
        while (TRUE) {
            if (tickets > 0) {
                tickets = tickets - 1;
                count += 1;
                NSString *threadName = [[NSThread currentThread] name];
                NSLog(@"执行了%ld次，还剩下%ld张票,线程名：%@",(long)count,(long)tickets,threadName);
            } else {
                break;
            }
        }
    }
}

#pragma mark - NSOperation
- (void)operationTest {
    NSInvocationOperation *invocationOption = [[NSInvocationOperation alloc]
                                               initWithTarget:self
                                               selector:@selector(downloadImage:)
                                               object:kURL];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperation:invocationOption];
}

- (void)operationsTest {
    tickets = 100;
    count = 0;
    NSMutableArray *arr = [NSMutableArray new];
    for (int i= 0; i < 3; i++) {
        NSInvocationOperation *invocationOption = [[NSInvocationOperation alloc]
                                                   initWithTarget:self
                                                   selector:@selector(run2)
                                                   object:nil];
        NSString *name = [NSString stringWithFormat:@"Thread-%d",(i+1)];
        [invocationOption setName:name];
        [arr addObject:invocationOption];
    }
    NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"------------------");
    }];
    [arr addObject:blockOperation];
    
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperations:arr waitUntilFinished:YES];
    [queue setMaxConcurrentOperationCount:4];
    
}

- (void)run2{
    while (TRUE) {
        if (tickets > 0) {
                tickets = tickets - 1;
                count += 1;
          //  NSString *threadName = [[NSOperationQueue currentQueue] name];
            NSLog(@"执行了%ld次，还剩下%ld张票,线程名：",(long)count,(long)tickets);
        } else {
            break;
        }
    }
}

#pragma mark - GCD
- (void)testAsync {
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *image = [weakSelf downloadImage2:kURL];
        if (image != nil) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }
    });
}

- (void)testGroupAsync {
    tickets = 100;
    count = 0;
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    dispatch_group_async(group, queue, ^{
        [self run2];
    });
    
    dispatch_group_async(group, queue, ^{
        [self run2];
    });
    
    dispatch_group_async(group, queue, ^{
        [self run2];
    });
    
    dispatch_group_notify(group, queue, ^{
        NSLog(@"updateUi");
    });
}

- (void)testBarrierAsync {
    dispatch_queue_t queue = dispatch_queue_create("gcdtest.rongfzh.yc", DISPATCH_QUEUE_CONCURRENT);
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"12");
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"33");
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"44");
    });
    
    dispatch_barrier_async(queue, ^{
        NSLog(@"dispatch_barrier_async");
        [NSThread sleepForTimeInterval:2];
    });
    
    dispatch_async(queue, ^{
        [NSThread sleepForTimeInterval:1];
        NSLog(@"55");
    });
    
}

- (UIImage *)downloadImage2:(NSString *)url {
    NSData *data = [[NSData alloc] initWithContentsOfURL:
                    [NSURL URLWithString:kURL]];
    UIImage *image = [[UIImage alloc]initWithData:data];
    return image;
}
@end
