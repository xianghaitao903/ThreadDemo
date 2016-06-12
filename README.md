# ThreadDemo

搬运自：<https://www.raywenderlich.com/60749/grand-central-dispatch-in-depth-part-1>

<http://www.raywenderlich.com/63338/grand-central-dispatch-in-depth-part-2>


##多线程术语
###Serial（串行）、Concurrent（并发）
任务串行执行就是每次只有一个任务被执行，任务并发执行就是在同一时间可以有多个任务被执行

###Synchronous(同步)、Asynchronous(异步)
同步函数在完成了它的预定任务后才返回。
异步函数会立即返回，预定的任务会完成但
是不会等待它完成，不会阻塞当前线程
###Critical Section 临界区
就是一段代码不能被并发执行，也就是两个线程不能同时执行这段代码。例如一个变量若能被并发进程访问，那么它的值不再可信
###Race Condition 竞态条件
这种状况是指基于特定序列或时机的事件的软件系统以不受控制的方式运行的行为。例如程序的并发任务执行的确切顺序
###Deadlock死锁
两个线程都卡住了，都在等待对方完成或执行其他操作，第一个不能完成是因为它在等待第二个的完成，第二个也不能完成，因为它在等待第一个的完成
###线程安全
线程安全的代码能够在多线程或并发任务中被安全的调用，而不会导致任何问题（数据损坏，崩溃，等），线程不安全的代码在某个时刻只能在一个上下文中运行，NSDictionary 是线程安全的，NSMutableDictionary 不是线程安全的。
###Context Switch 上下文切换
一个上下文切换指当你在单个进程里切换执行不同的线程时存储与恢复执行状态的过程
###Concurrency(并发)与Parallelism(并行)
并发代码的不同部分可以同步执行。该怎样发生或是否发生都取决于系统。多核设备通过并行来同时执行多个线程；为了是单核设备也能实现这一点，他们必须先运行一个线程，执行一个上下文切换，然后运行另一个线程或进程，这通常发生的足够快，以致给我们并发执行的错觉


##NSThread
有两个初始化方法:<br/>

	//类方法
	[NSThread detachNewThreadSelector:@selector(downloadImage:) toTarget:self withObject:kURL];
	
	//实例方法
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(downloadImage:) withObject:kURL];
	[thread start];
	
使用

	 performSelectorOnMainThread: withObject: waitUntilDone: 
回到主线程执行对应的方法
###NSLock 和 NSCondition
	NSLock *lock = [[NSLock alloc] init];
	//线程中使用数据前
	[lock lock];
	
	//使用完成过后
	[lock unlock];
	
	//与 NSLock 的区别在于，可以用于线程之间的唤醒
	NSCondition *theCondition = [[NSCondition alloc] init];
	
	//Thread1
	[theCondition lock];
	[theCondition wait];
	
	[theCondition unlock];
	
	//Thread2 
	[theCondition lock];
	//执行操作过后，唤醒Thread1
	[theCondition signal];
	[theCondition unlock];
	
	
##NSOperation
###NSOperationQueue、NSOperation、NSInvocationOperation和NSBlockOperation;

NSOperationQueue 为线程队列，添加NSOperation对象  
NSOperation 为NSInvocationOperation和NSBlockOperation的父类。 
 
	NSOperationQueue *queue = [[NSOperationQueue alloc] init];
	NSInvocationOperation *invocationOperation = [[NSInvocationOperation alloc] initWithTarget:self selector(run) object:nil];
	[queue addOperation:invocationOperation]; 
	
	NSBlockOperation *blockOperation = [NSBlockOperation blockOperationWithBlock:^{
	NSLog(@"------------");
	}];
	[queue addOperation:blockOperation];
	
	//，最大并行数  设置为1表示是串行，默认为-1表示无限制
	[queue setMaxConcurrentOperationCount:4];
	//添加依赖
	[invocationOperation addDependency:blockOperation]; 
	
通过继承NSOperation的方式自定义 NSOperation; 必须重写main 方法
	 	
	- (void) main {
		@autoreleasepool{
		
		}
	}
##GCD
###Queue(队列)
GCD提供 dispatch queues 来处理代码 先进入队列的任务先开始，直到队列的终点。

所有的调度队列，自身都是线程安全的。

###Serial Queues(串行队列)
队列中的任务一次执行一个，每个任务在前一个任务完成之后才开始。

###concurrent Queues(并发队列)
也是按添加的顺序执行，但是完成的顺序无法确定。

###Queue Types(队列类型)
main queue :主队列，串行队列，一次只能执行一个任务，唯一可以用来更新UI的线程
系统提供四个全局队列（并行队列） global dispatch queues 分别为 background low default high,  Apple的API也会调用这些队列，所以添加的任务不会是这些队列中的唯一任务，这些全局队列不需要释放

###dispatch_sync 
	NSLog("1");
	dispatch_sync(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY,0),^{
	NSLog("2");
	})
	NSLog("3");

添加一个任务到队列并等待，直到任务结束。
###dispatch_async
	NSLog("1");
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HEIGHT,0),^{
	NSLog("2");
	})
	NSLog("3");
无法决定哪个先执行并行的
###dispatch_group_async,dispatch_group_notify
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
dispatch_group_async 并行执行 dispatch_group_async 全部完成过后 执行dispatch_group_notify


###dispatch_barrier_async
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
前面的任务执行完成后才执行 dispatch_barrier_async， 后面的等 dispatch_barrier_async 执行完成过后再执行
不要用于自定义串行队列，和全局并发队列，串行队列一次只执行一个操作,全局队列系统可能在使用，不能垄断它们只为你自己的目的，用于自定义的并发队列

###dispatch_after延后工作
	- (void)showOrHideNavPrompt {
		dpuble delayInSeconds = 1.0;
		dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,(int64_t)(delayInSeconds * NSEC_PER_SEC));	
		dispatch_after(popTime,dispatch_get_main_queue(),^(void){
			//code
		})
	}

##单例线程安全
	+(instancetype)sharedUser {
		static User *sharedUser = nil;
		static dispatch_once_t onceToken;
		dispatch_once(&onceToken,^{
			sharedUser = [[User alloc] init];
			sharedUser.arr = [NSMutableArray array];
		});
		return sharedUser;
	}
只是让访问共享实例线程安全，它没有让类本身线程安全，类中还有其他竞态条件，例如任何操作内部数据的情况，需要其他方式来保证线程安全，例如同步访问数据






##RunLooper
	
	
	
	
	