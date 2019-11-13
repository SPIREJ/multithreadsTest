//
//  NSThreadViewController.m
//  multithreadsTest
//
//  Created by JackMa on 2019/11/13.
//  Copyright © 2019 fire. All rights reserved.
//

#import "NSThreadViewController.h"

@interface NSThreadViewController ()

@end

@implementation NSThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self demo1];
    
    [self demo2];
    
    [self demo3];
}

#pragma mark - 创建线程 启动线程 执行任务

- (void)demo1 {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run1) object:nil];
    [thread start];
}

- (void)run1 {
    NSLog(@"run1 -- %@", [NSThread currentThread]);
}

#pragma mark - 隐式创建线程并启动线程 block中执行任务

- (void)demo2 {
    [NSThread detachNewThreadWithBlock:^{
        NSLog(@"隐式创建并启动线程，并在block中执行任务 --- %@", [NSThread currentThread]);
    }];
}

#pragma mark - 隐式创建线程并启动线程 select中执行任务

- (void)demo3 {
    [NSThread detachNewThreadSelector:@selector(run2) toTarget:self withObject:nil];
}

- (void)run2 {
    NSLog(@"run2 -- %@", [NSThread currentThread]);
}

@end
