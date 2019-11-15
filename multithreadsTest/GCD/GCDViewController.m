//
//  GCDViewController.m
//  multithreadsTest
//
//  Created by JackMa on 2019/11/13.
//  Copyright © 2019 fire. All rights reserved.
//

#import "GCDViewController.h"

@interface GCDViewController ()

@end

@implementation GCDViewController

/**
关于队列的说明:
1:来了一个任务 -->
2:线程调度池发觉有了任务过来,先去找有没有闲置的队列
   2.1:如果有就会把任务加到队列上
   2.2:如果没有就会创建队列,并把任务加到队列上去
3:调度队列中的任务在线程执行
4:执行完毕就会闲置队列,超出时限就会销毁队列
*/

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    [self demo0];
    
//    [self demo1];
    
//    [self demo2];
    
//    [self demo3];
    
//    [self demo4];
    
//    [self demo5];
    
//    [self demo6];
    
//    [self demo7];
    
//    [self demo8];
    
//    [self demo9];
    
//    [self demo10];
    
//    [self demo11];
    
//    [self demo12];
    
    [self demo13];
}

#pragma mark - 还原最基础的写法

- (void)demo0{
    
    //1:创建串行队列
    dispatch_queue_t queue = dispatch_queue_create("demo0", DISPATCH_QUEUE_SERIAL);
    
    //2:创建任务
    dispatch_block_t taskBlock = ^{
        NSLog(@"%@",[NSThread currentThread]);
    };
    //3:利用函数把任务放入队列
    dispatch_sync(queue, taskBlock);
}

#pragma mark - 同步异步并发串行现象

- (void)demo1 {
    // 串行队列
    dispatch_queue_t queue = dispatch_queue_create("demo1", DISPATCH_QUEUE_SERIAL);
    NSLog(@"1");
    // 异步 不堵塞
    dispatch_async(queue, ^{
        NSLog(@"2");
        // 同步 堵塞
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    
    // 打印是什么？？ 1 5 2 崩溃
}

- (void)demo2 {
    // 并发队列
    dispatch_queue_t queue = dispatch_queue_create("demo2", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    // 异步 不堵塞
    dispatch_async(queue, ^{
        NSLog(@"2");
        // 同步 堵塞
        dispatch_sync(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    
    // 打印是什么？？ 1 5 2 3 4
}

- (void)demo3 {
    // 并发队列
    dispatch_queue_t queue = dispatch_queue_create("demo3", DISPATCH_QUEUE_CONCURRENT);
    NSLog(@"1");
    // 异步 不堵塞
    dispatch_async(queue, ^{
        NSLog(@"2");
        // 异步 畅通无阻 不堵塞
        dispatch_async(queue, ^{
            NSLog(@"3");
        });
        NSLog(@"4");
    });
    NSLog(@"5");
    
    // 执行顺序是什么？？ 1 5 2 4 3
}

#pragma mark - 主队列同步，不会开启新线程，在主线程中执行

- (void)demo4 {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        for (int i = 0; i < 20; i++) {
            dispatch_sync(dispatch_get_main_queue(), ^{
                NSLog(@"%d-%@", i, [NSThread currentThread]);
            });
        }
    });
    NSLog(@"hello demo4 - 主线程同步，不会开启新线程");
}

#pragma mark - 主队列异步，不会开启新线程，顺序执行

- (void)demo5 {
    for (int i = 0; i < 20; i++) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSLog(@"%d-%@", i, [NSThread currentThread]);
        });
    }
    NSLog(@"hello demo5 - 主线程异步，不会开启新线程，顺序执行");
}

#pragma mark - 同步并发，不开线程:就算并发出来,没有坑位接受,所以顺序执行

- (void)demo6 {
    dispatch_queue_t queue = dispatch_queue_create("demo6", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 20; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%d-%@", i, [NSThread currentThread]);
        });
    }
}

#pragma mark - 异步并发，开新线程，没有顺序

- (void)demo7 {
    dispatch_queue_t queue = dispatch_queue_create("demo7", DISPATCH_QUEUE_CONCURRENT);
    for (int i = 0; i < 20; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%d-%@", i, [NSThread currentThread]);
        });
    }
}

#pragma mark - 同步串行
/*
 1:同步执行：一行一行代码从上向下执行，当前代码不执行完成，不会执行后续代码 同步不会开启线程
 2:串行队列：一个一个的调度任务，前一个任务没有执行完成，不会调度后面的任务
*/
- (void)demo8 {
    dispatch_queue_t queue = dispatch_queue_create("demo8", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 20; i++) {
        dispatch_sync(queue, ^{
            NSLog(@"%d-%@", i, [NSThread currentThread]);
        });
    }
}

#pragma mark - 异步串行，会开启线程，串行执行

- (void)demo9 {
    dispatch_queue_t queue = dispatch_queue_create("demo9", DISPATCH_QUEUE_SERIAL);
    for (int i = 0; i < 20; i++) {
        dispatch_async(queue, ^{
            NSLog(@"%d-%@", i, [NSThread currentThread]);
        });
    }
}

#pragma mark - 栅栏方法，必须是自定义并发队列才有效

- (void)demo10 {
    dispatch_queue_t queue = dispatch_queue_create("demo10", DISPATCH_QUEUE_CONCURRENT);
    dispatch_queue_t queue1 = dispatch_queue_create("demo10_spirej", DISPATCH_QUEUE_CONCURRENT);
    
    // 1. 异步任务
    dispatch_async(queue, ^{
        for (int i = 0; i < 5; i++) {
            NSLog(@"download1-%d-%@",i,[NSThread currentThread]);
        }
    });
    
    for (int i = 0; i < 5; i++) {
        dispatch_async(queue, ^{
            NSLog(@"download1-%d-%@",i,[NSThread currentThread]);
        });
    }
    
    // 2. 栅栏函数
    dispatch_barrier_async(queue, ^{
        NSLog(@"---------------------%@------------------------",[NSThread currentThread]);
    });
    
    NSLog(@"加载那么多,喘口气!!!");
    
    // 3. 异步函数
    dispatch_async(queue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"日常处理3-%zd-%@",i,[NSThread currentThread]);
        }
    });
    NSLog(@"************起来干!!");
    
    dispatch_async(queue, ^{
        for (NSUInteger i = 0; i < 5; i++) {
            NSLog(@"日常处理4-%zd-%@",i,[NSThread currentThread]);
        }
    });
}

#pragma mark - 调度组

- (void)demo11 {
    // 创建调度组
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_queue_create("demo11", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
       // 追加任务1
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:1.0];        // 模拟耗时操作
            NSLog(@"1---%@", [NSThread currentThread]); // 打印当前线程
        }
    });
    
    dispatch_group_async(group, queue, ^{
        // 追加任务2
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"2---%@", [NSThread currentThread]);
        }
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        // 等待前面的异步任务1、任务2都执行完毕后，回到主线程执行下边的任务
        for (int i = 0; i < 2; ++i) {
            [NSThread sleepForTimeInterval:1.0];
            NSLog(@"3---%@", [NSThread currentThread]);
        }
        NSLog(@"group---end");
    });
}

#pragma mark - 调度组内部方法 enter - leave

- (void)demo12{
    
    // 问题: 如果 dispatch_group_enter 多 dispatch_group_leave 不会调用通知
    // dispatch_group_enter 少 dispatch_group_leave  奔溃
    // 成对存在
    
    dispatch_group_t group = dispatch_group_create();
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"第一个走完了");
        dispatch_group_leave(group);
    });
    
    dispatch_group_enter(group);
    dispatch_async(queue, ^{
        NSLog(@"第二个走完了");
#warning mark - 少一个leave
    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        NSLog(@"所有任务完成,可以更新UI");
    });
}

#pragma mark - 信号量

- (void)demo13 {
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    // 信号量 -- gcd控制并发数
    // 同步 为1
    //总结：由于设定的信号值为3，先执行三个线程，等执行完一个，才会继续执行下一个，保证同一时间执行的线程数不超过3
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(2);
    
    //任务1
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"执行任务1");
        sleep(1);
        NSLog(@"任务1完成");
        dispatch_semaphore_signal(semaphore);
    });
    
    //任务2
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"执行任务2");
        sleep(1);
        NSLog(@"任务2完成");
        dispatch_semaphore_signal(semaphore);
    });
    
    //任务3
    dispatch_async(queue, ^{
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        NSLog(@"执行任务3");
        sleep(1);
        NSLog(@"任务3完成");
        dispatch_semaphore_signal(semaphore);
    });
}

@end
