//
//  PingManager.m
//  PingDemo
//
//  Created by shenhongbang on 16/8/19.
//  Copyright © 2016年 中移(杭州)信息技术有限公司. All rights reserved.
//

#import "PingManager.h"
#import "SimplePing.h"

@interface PingManager ()

@property (nonatomic, strong) SimplePing *ping;

@property (nonatomic, copy) NSString *host;                     //要检测的host

@property (nonatomic, strong) NSMutableDictionary *succDic;
@property (nonatomic, strong) NSMutableDictionary *faDic;

@end

@implementation PingManager


+ (instancetype)sharedInstanceHost:(NSString *)host success:(void (^)())success failure:(void (^)())failure {
    static PingManager *manager = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[PingManager alloc] init];
    });
    
    manager ->_host = host;
    [manager -> _succDic setObject:success forKey:host];
    [manager -> _faDic setObject:failure forKey:host];
    
    return manager;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _succDic = [NSMutableDictionary dictionaryWithCapacity:0];
        _faDic = [NSMutableDictionary dictionaryWithCapacity:0];
    }
    return self;
}

+ (void)shb_PingWithHost:(NSString *)host success:(void (^)())success failure:(void (^)())failure {
    PingManager *manager = [PingManager sharedInstanceHost:host success:success failure:failure];
    [manager go];
}


- (void)go {
    _ping = [[SimplePing alloc] initWithHostName:_host];
    _ping.delegate = self;
    [_ping start];
}

- (void)killPing {
    [_ping stop];
    _ping = nil;
}

- (void)check {
    if (_ping != nil) {
        [self pingFailure];
    }
}

- (void)pingFailure {
    void(^temp)() = _faDic[_host];
    if (temp) {
        temp();
    }
    [self killPing];
}

- (void)pingSuccess {
    void(^temp)() = _succDic[_host];
    if (temp) {
        temp();
    }
    [self killPing];
}

#pragma mark - SimplePingDelegate
- (void)SimplePing:(SimplePing *)pinger didStartWithAddress:(NSData *)address {
    [_ping sendPingWithData:nil];
}

- (void)SimplePing:(SimplePing *)pinger didFailWithError:(NSError *)error {
    [self pingFailure];
}

- (void)SimplePing:(SimplePing *)pinger didSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    [self performSelector:@selector(check) withObject:nil afterDelay:0.1];
}


- (void)SimplePing:(SimplePing *)pinger didFailToSendPacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber error:(NSError *)error {
    [self pingFailure];
}


- (void)SimplePing:(SimplePing *)pinger didReceivePingResponsePacket:(NSData *)packet sequenceNumber:(uint16_t)sequenceNumber {
    [self pingSuccess];
}

- (void)SimplePing:(SimplePing *)pinger didReceiveUnexpectedPacket:(NSData *)packet {
    [self pingSuccess];
}

@end
