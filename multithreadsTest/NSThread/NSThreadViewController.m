//
//  NSThreadViewController.m
//  multithreadsTest
//
//  Created by JackMa on 2019/11/13.
//  Copyright © 2019 fire. All rights reserved.
//

#import "NSThreadViewController.h"

@interface NSThreadViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (nonatomic, assign) NSInteger ticketSurplusCount;
@property (nonatomic, strong) NSThread *ticketSaleWindow1;
@property (nonatomic, strong) NSThread *ticketSaleWindow2;
@end

@implementation NSThreadViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self demo1];
    
    [self demo2];
    
    [self demo3];
    
    [self demo4];
    
//    [self demo5];
    
    [self demo6];
}

#pragma mark - 创建线程 启动线程 执行任务

- (void)demo1 {
    NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(run1) object:nil];
    BOOL isMainThread = [thread isMainThread];
    thread.name = @"demo1_thread";
    NSLog(@"%@%@主线程", thread.name, isMainThread?@"是":@"不是");
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

#pragma mark - 线程之间的通信

- (void)demo4 {
    [self downloadImageOnSubThread];
}

/**
* 创建一个线程下载图片
*/
- (void)downloadImageOnSubThread {
    // 在创建的子线程中调用downloadImage下载图片
    [NSThread detachNewThreadSelector:@selector(downloadImage) toTarget:self withObject:nil];
}

/**
* 下载图片，下载完之后回到主线程进行 UI 刷新
*/
- (void)downloadImage {
    NSLog(@"current thread -- %@", [NSThread currentThread]);

    // 1. 获取图片 imageUrl
    NSURL *imageUrl = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1573669426386&di=5c5bed95bdfe3465aa28373d9545289e&imgtype=0&src=http%3A%2F%2Fgss0.baidu.com%2F9fo3dSag_xI4khGko9WTAnF6hhy%2Fzhidao%2Fpic%2Fitem%2F0823dd54564e925863c059ec9482d158ccbf4e38.jpg"];

    // 2. 从 imageUrl 中读取数据(下载图片) -- 耗时操作
    NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
    // 通过二进制 data 创建 image
    UIImage *image = [UIImage imageWithData:imageData];

    // 3. 回到主线程进行图片赋值和界面刷新
    [self performSelectorOnMainThread:@selector(refreshOnMainThread:) withObject:image waitUntilDone:YES];
}

/**
* 回到主线程进行图片赋值和界面刷新
*/
- (void)refreshOnMainThread:(UIImage *)image {
    NSLog(@"current thread -- %@", [NSThread currentThread]);

    // 赋值图片到imageview
    self.imageView.image = image;
}

#pragma mark - 多线程非安全

- (void)demo5 {
    [self initTicketStatusNotSafe];
}

/**
* 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
*/
- (void)initTicketStatusNotSafe {
    // 1. 设置剩余火车票为 50
    self.ticketSurplusCount = 50;

    // 2. 设置北京火车票售卖窗口的线程
    self.ticketSaleWindow1 = [[NSThread alloc]initWithTarget:self   selector:@selector(saleTicketNotSafe) object:nil];
    self.ticketSaleWindow1.name = @"北京火车票售票窗口";

    // 3. 设置上海火车票售卖窗口的线程
    self.ticketSaleWindow2 = [[NSThread alloc]initWithTarget:self   selector:@selector(saleTicketNotSafe) object:nil];
    self.ticketSaleWindow2.name = @"上海火车票售票窗口";

    // 4. 开始售卖火车票
    [self.ticketSaleWindow1 start];
    [self.ticketSaleWindow2 start];
}

/**
* 售卖火车票(非线程安全)
*/
- (void)saleTicketNotSafe {
    while (1) {
        //如果还有票，继续售卖
        if (self.ticketSurplusCount > 0) {
            self.ticketSurplusCount --;
            NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@",self.ticketSurplusCount, [NSThread currentThread].name]);
        [NSThread sleepForTimeInterval:0.2];
        
    }else {//如果已卖完，关闭售票窗口
        NSLog(@"所有火车票均已售完");
        break;
        }
    }
}

#pragma mark - 多线程安全

- (void)demo6 {
    [self initTicketStatusSafe];
}

/**
 * 初始化火车票数量、卖票窗口(非线程安全)、并开始卖票
 */
- (void)initTicketStatusSafe {
    // 1. 设置剩余火车票为 50
    self.ticketSurplusCount = 50;
    
    // 2. 设置北京火车票售卖窗口的线程
    self.ticketSaleWindow1 = [[NSThread alloc]initWithTarget:self     selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow1.name = @"北京火车票售票窗口";
    
    // 3. 设置上海火车票售卖窗口的线程
    self.ticketSaleWindow2 = [[NSThread alloc]initWithTarget:self     selector:@selector(saleTicketSafe) object:nil];
    self.ticketSaleWindow2.name = @"上海火车票售票窗口";
    
    // 4. 开始售卖火车票
    [self.ticketSaleWindow1 start];
    [self.ticketSaleWindow2 start];
}

/**
 * 售卖火车票(非线程安全)
 */
- (void)saleTicketSafe {
    while (1) {
        @synchronized(self) {
            //如果还有票，继续售卖
            if (self.ticketSurplusCount > 0) {
                self.ticketSurplusCount --;
                NSLog(@"%@", [NSString stringWithFormat:@"剩余票数：%ld 窗口：%@",self.ticketSurplusCount, [NSThread currentThread].name]);
                [NSThread sleepForTimeInterval:0.2];
                
            }else {//如果已卖完，关闭售票窗口
                NSLog(@"所有火车票均已售完");
                break;
            }
        }
    }
}

@end
