//
//  HTSViewController.m
//  HTSVideoPlay
//
//  Created by SongLi.02 on 11/17/2016.
//  Copyright (c) 2016 SongLi.02. All rights reserved.
//

#import "HTSViewController.h"
#import <TTRoute/TTRoute.h>
#import <TTURLUtils.h>
#import <HTSVideoPageParamHeader.h>
#import <HTSVideoDetailModelHelper.h>

static NSString * const JSONModelString = @"{\"id\": 6410152683436510466,\"title\": \"\",\"text\": \"你们要的李白出装\",\"location\": \"伊春\",\"duration\": 14.467,\"video_detail_info\": {\"video_watch_count\": 43,\"video_url\": [\"http://v3.365yg.com/a1ac2edb43129e60c6c9b8d682553b60/58f784dd/video/m/220e246541e6810410297826f754b519cee1145cb3000012a721550e7e/\",\"https://api.huoshan.com/hotsoon/item/video/_playback/?video_id=a76baaa671b64c9b8ebe45832b22e7a2&line=0\",\"https://api.huoshan.com/hotsoon/item/video/_playback/?video_id=a76baaa671b64c9b8ebe45832b22e7a2&line=1\"],\"video_id\": \"0484661ef29b40449ae8665839ff2f16\",\"detail_video_large_image\": {\"url\": \"http://p9.pstatp.com/large/1c86000f08deb644b14d.jpg\",\"width\": 540,\"height\": 960,\"uri\": \"large/1c86000f08deb644b14d\",\"url_list\":{\"url\":\"http://p3.pstatp.com/large/1ca0000022b4691e6502.jpg\",\"url\":\"http://p3.pstatp.com/large/1ca0000022b4691e6502.jpg\",\"url\":\"http://p3.pstatp.com/large/1ca0000022b4691e6502.jpg\"}}},\"open_url\":\"sslocal://huoshanvideo?video_id=6408454940020182274&request_id=0&source_from=xxx\",\"open_hotsoon_url\": \"sslocal://item?id=6408454940020182274\",\"user_info\": {\"avatar_url\": \"http://p3.pstatp.com/live/100x100/123f00112b957d81dbbf.jpg\",\"name\": \"王者荣耀~狼哥\",\"description\": \"我能不能上惹门就看你们了佬帖们！\",\"user_id\": 54562198931,\"follower_count\": 0,\"user_auth_info\": \"\",\"user_verified\": false,\"verified_content\":\" 户外运动资讯专家\",\"follow\": true},\"comment_count\": 2,\"digg_count\": 1,\"share_count\": 0,\"user_digg\": 0,\"tips\": \"火力积攒中\",\"tips_url\": \"https://hotsoon.snssdk.com/hotsoon/in_app/video_qa/\",\"share_title\": \"「王者荣耀~狼哥」的这个视频好棒，快来围观！\",\"share_description\": \"我能不能上惹门就看你们了佬帖们！\",\"share_url\": \"https://www.huoshan.com/share/video/6410152683436510466/?tag=0\",\"behot_time\": 1492084720,\"cursor\": 1492084720000,\"rid\": \"\"}";

static NSString * const JSONABModelString = @"{\"op_read_comment\":{\"enable\":true, \"text\":\"op_read_comment\"}, \"op_write_comment\":{\"enable\":false, \"text\":\"op_write_comment\"}, \"op_reply_comment\":{\"enable\":false, \"text\":\"op_reply_comment\"}, \"op_digg_video\":{\"enable\":false, \"text\":\"op_digg_video\"}, \"op_digg_comment\":{\"enable\":false, \"text\":\"op_digg_comment\"}, \"op_follow\":{\"enable\":false, \"text\":\"op_follow\"}, \"op_go_profile\":{\"enable\":true, \"text\":\"op_go_profile\"}}";

@interface HTSViewController ()

@end

@implementation HTSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*
     HTSVideoPageParamVideoId     : @"6408342767033912577",
     HTSVideoPageParamSource      : @"toutiao_tab",
     HTSVideoPageParamRequstId    : @"123"
     */
    
    UIImageView *bgImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"full"]];
    [self.view addSubview:bgImageView];
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, CGRectGetHeight(self.view.bounds) / 2.0 - 30, CGRectGetWidth(self.view.bounds), 60)];
    button.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
    [button setTitle:@"进入火山小视频" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(onButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
}

- (void)onButtonClicked:(id)sender
{
    NSURL *url = [TTURLUtils URLWithString:@"sslocal://huoshanvideo/"];
    
    NSDictionary *modelDict = [NSJSONSerialization JSONObjectWithData:[JSONModelString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    //NSDictionary *abModelDict = [NSJSONSerialization JSONObjectWithData:[JSONABModelString dataUsingEncoding:NSUTF8StringEncoding] options:NSJSONReadingAllowFragments error:nil];
    
    UIImageView *topImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"top"]];
    UIImageView *middleImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"full"]];
    UIImageView *bottomImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bottom"]];
    bottomImageView.frame = CGRectMake(0, CGRectGetHeight(self.view.bounds) - CGRectGetHeight(bottomImageView.bounds), CGRectGetWidth(bottomImageView.bounds), CGRectGetHeight(bottomImageView.bounds));
    CGRect cellFrame = CGRectMake(321.0 / 2.0, -168.0 / 2.0, 319.0 / 2.0, 514.0 / 2.0);
//    CGRect cellFrame = CGRectMake(321.0 / 2.0, 0.0 / 2.0, 319.0 / 2.0, 346.0 / 2.0);
    
    NSDictionary *params = @{
                             HTSVideoPageParamVideoId           : @"6410152683436510466",
                             HTSVideoPageParamSource            : @"toutiao_tab",
                             HTSVideoPageParamRequstId          : @"123",
                             HTSVideoPageParamVideoModelDict    : modelDict,
                             HTSVideoPageParamTransition        : @{@"topView":topImageView, @"middleView":middleImageView, @"bottomView":bottomImageView, @"cellFrame":NSStringFromCGRect(cellFrame)},
                             };
    //TTRoute 0.2.0
    //[[TTRoute sharedRoute] openURLByPushViewController:url userInfo:[[TTRouteUserInfo alloc] initWithInfo:params]];
    
    //TTRoute 0.1.4
    [[TTRoute sharedRoute] openURL:url baseCondition:@{kSSAppPageBaseConditionParamsKey : params}];
}

@end
