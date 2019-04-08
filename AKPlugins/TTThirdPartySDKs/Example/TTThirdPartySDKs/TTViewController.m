//
//  TTViewController.m
//  TTThirdPartySDKs
//
//  Created by fengyadong on 12/05/2016.
//  Copyright (c) 2016 fengyadong. All rights reserved.
//

#import "TTViewController.h"
#import <AlipaySDK/AlipaySDK.h>
#import "APOpenAPI.h"
#import <DTShareKit/DTOpenAPI.h>
#import <TencentOpenAPI/TencentOAuth.h>
#import "WechatAuthSDK.h"
#import "WeiboSDK.h"

@interface TTViewController ()

@end

@implementation TTViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    NSLog(@"阿里paySDK版本号:%@", [[AlipaySDK defaultService] currentVersion]);
    NSLog(@"阿里shareSDK版本号:%@", [APOpenAPI getApiVersion]);
    NSLog(@"钉钉shareSDK版本号:%@", [DTOpenAPI openAPIVersion]);
    NSLog(@"QQSDK版本号:%@",[TencentOAuth sdkVersion]);
    NSLog(@"微信版本号:%@",[[[WechatAuthSDK alloc] init] sdkVersion]);
    NSLog(@"微博版本号:%@",[WeiboSDK getSDKVersion]);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
