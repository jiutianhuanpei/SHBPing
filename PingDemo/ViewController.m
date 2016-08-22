//
//  ViewController.m
//  PingDemo
//
//  Created by shenhongbang on 16/8/19.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "ViewController.h"
#import "SimplePing.h"
#import "PingManager.h"

NSString *const kHostAddress = @"172.23.27.131:9101";//172.23.27.131:9101  //192.168.91.229:9101
NSString *const host = @"172.23.27.131";

@interface ViewController ()<SimplePingDelegate>

@property (weak, nonatomic) IBOutlet UITextField *inputView;
@property (weak, nonatomic) IBOutlet UITextView *outputView;

@end

@implementation ViewController {
    
    NSTimer         *_timer;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _outputView.text = nil;
   
    
}

- (IBAction)begainPing:(UIButton *)sender {
    
    [_timer invalidate];
    _timer = nil;
    _timer = [NSTimer scheduledTimerWithTimeInterval:0.15 target:self selector:@selector(start) userInfo:nil repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
}

- (void)start {
    __block NSString *temp = nil;
    
    if (arc4random() % 2) {
        [PingManager shb_PingWithHost:@"www.baidu.com" success:^{
            temp = @"www.baidu.com   success";
            _outputView.text = [NSString stringWithFormat:@"%@\n%@", _outputView.text, temp];

        } failure:^{
            temp = @"www.baidu.com   failure";
            _outputView.text = [NSString stringWithFormat:@"%@\n%@", _outputView.text, temp];

        }];

    } else {
        [PingManager shb_PingWithHost:host success:^{
            temp = [NSString stringWithFormat:@"%@    success", host];
            _outputView.text = [NSString stringWithFormat:@"%@\n%@", _outputView.text, temp];

        } failure:^{
            temp = [NSString stringWithFormat:@"%@    failure", host];
            _outputView.text = [NSString stringWithFormat:@"%@\n%@", _outputView.text, temp];

        }];
    }
    
}

- (IBAction)endPing:(id)sender {
    
    [_timer invalidate];
    _timer = nil;
    
}





- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
