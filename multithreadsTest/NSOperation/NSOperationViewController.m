//
//  NSOperationViewController.m
//  multithreadsTest
//
//  Created by JackMa on 2019/11/15.
//  Copyright © 2019 fire. All rights reserved.
//

#import "NSOperationViewController.h"

@interface NSOperationViewController ()

@end

@implementation NSOperationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self demo0];
    
//    [self demo1];
    
//    [self demo2];
    
//    [self demo3];
    
//    [self demo4];
    
//    [self demo5];
    
//    [self demo6];
    
    [self demo7];
}

#pragma mark - 依赖 addDependency

- (void)demo7 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"先下载第一段数据 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0];
    }];
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"拿到第一段数据去下载第二段数据 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0];
    }];
    
    NSBlockOperation *bo3 = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"前两段数据下载完成，开始下载第三段数据 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0];
    }];
    
    [bo2 addDependency:bo1];
    [bo3 addDependency:bo2];
    
    [queue addOperations:@[bo1, bo2, bo3] waitUntilFinished:NO];
}

#pragma mark - maxConcurrentOperationCount设置最大并发数
// GCD 控制并发数 -- 信号量 (1) -- 同步

- (void)demo6 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = @"spirej";
    queue.maxConcurrentOperationCount = 3;
    for (int i = 0; i < 10; i++) {
        [queue addOperationWithBlock:^{
            NSLog(@"%d -- %@", i, [NSThread currentThread]);
            [NSThread sleepForTimeInterval:2.0];
        }];
    }
}

#pragma mark - 线程通讯

- (void)demo5 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    [queue addOperationWithBlock:^{
        NSLog(@"%@ = %@",[NSOperationQueue currentQueue],[NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0];
        [[NSOperationQueue mainQueue] addOperationWithBlock:^{
            NSLog(@"%@ = %@",[NSOperationQueue currentQueue],[NSThread currentThread]);
        }];
    }];
}

#pragma mark - 优先级，只会让CPU有更高的几率调用，不是说设置高就一定全部先完成

- (void)demo4 {
    NSBlockOperation *bo1 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"第一个操作 %d -- %@", i, [NSThread currentThread]);
        }
    }];
    bo1.queuePriority = NSOperationQueuePriorityVeryHigh;
    
    NSBlockOperation *bo2 = [NSBlockOperation blockOperationWithBlock:^{
        for (int i = 0; i < 10; i++) {
            NSLog(@"第二个操作 %d -- %@", i, [NSThread currentThread]);
        }
    }];
    bo2.queuePriority = NSOperationQueuePriorityVeryLow;
    
    //2:创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    //3:添加到队列
    [queue addOperation:bo1];
    [queue addOperation:bo2];
}

#pragma mark - 测试操作与队列的执行效果：异步并发

- (void)demo3 {
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    for (int i = 0; i < 20; i++) {
        [queue addOperationWithBlock:^{
            [NSThread sleepForTimeInterval:0.5];
            NSLog(@"%d---%@", i, [NSThread currentThread]);
        }];
    }
}

#pragma mark - NSBlockOperation创建事物

- (void)demo2 {
    // 使用NSBlockOperation创建事物
    NSBlockOperation *bo = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"这是一个执行代码块 - %@", [NSThread currentThread]);
        [NSThread sleepForTimeInterval:2.0];
    }];
    
    // 1.1 添加其他操作（执行代码块）
    [bo addExecutionBlock:^{
        NSLog(@"这是另一个执行代码块 - %@", [NSThread currentThread]);
    }];
    
    [bo addExecutionBlock:^{
        NSLog(@"这也是一个执行代码块 - %@", [NSThread currentThread]);
    }];
    
    // 1.2 设置监听
    bo.completionBlock = ^{
        NSLog(@"完成了");
    };
    // 2.创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 3.事物添加到队列
    [queue addOperation:bo];
    NSLog(@"事务添加进了NSOperationQueue - %@", [NSThread currentThread]);
}

#pragma mark - 调用start方法手动启动任务

- (void)demo1 {
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleInvocation:) object:nil];
    [op start];
}

#pragma mark - NSInvocationOperation : 创建操作 ---> 创建队列 ---> 操作加入队列

- (void)demo0 {
    // 创建操作
    NSInvocationOperation *op = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(handleInvocation:) object:@"spirej"];
    // 创建队列
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    // 操作加入队列
    [queue addOperation:op];
}

- (void)handleInvocation:(id)op {
    NSLog(@"%@ -- %@", op, [NSThread currentThread]);
}

@end
