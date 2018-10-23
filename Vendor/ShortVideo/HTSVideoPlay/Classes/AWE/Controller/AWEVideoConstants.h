//
//  AWEVideoConstants.m
//  Pods
//
//  Created by 01 on 17/6/15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, AWEVideoDetailCloseStyle)
{
    AWEVideoDetailCloseStyleNavigationPan = 0,
    AWEVideoDetailCloseStyleCloseButton,
    AWEVideoDetailCloseStylePullPanDown,
};

static NSInteger const CommentFetchCount = 20;

static NSString * const CommentCellIdentifier = @"COMMENT_CELL_IDENTIFIER";

static NSString * const AWEVideoGroupId = @"group_id";

static NSString * const AWEVideoRequestId = @"request_id";

static NSString * const AWEVideoEnterFrom = @"enter_from";

static NSString * const VideoGroupSource = @"group_source";

static NSString * const AWEVideoShowComment = @"show_comment";

static NSString * const AWEVideoPageParamVideoId = @"item_id";

static NSString * const AWEVideoCategoryName = @"category_name";

static NSString * const AWEVideoRuleId = @"rid";

static NSString * const TTAdGroupSource = @"3";

static NSString * const HotsoonGroupSource = @"16";

static NSString * const AwemeGroupSource = @"19";

static NSString * const ToutiaoGroupSource = @"21";

static NSInteger const ShowCommentModal = 1;

static NSInteger const ShowKeyboardOnly = 2;

static NSString * const AwemeSchemaPrefix = @"snssdk1128://";

static NSString * const HotSoonSchemaPrefix = @"snssdk1112://";

static NSString * const AwemeIconDownloadUrl = @"https://d.douyin.com/Stvr/";

static NSString * const HotSoonIconDownloadUrl = @"http://d.huoshanzhibo.com/UsSo/";

static NSString * const AwemeBannerDownloadUrl = @"https://d.douyin.com/6m6M/";

static NSString * const HotSoonBannerDownloadUrl = @"http://d.huoshanzhibo.com/hPbE/";

static NSString * const HotSoonTabPicturePromotionDownloadUrl = @"http://d.huoshanzhibo.com/6ccn/";

static NSString * const AwemeTabPicturePromotionDownloadUrl = @"https://d.douyin.com/22c/";

/// 显示非WiFi 弹窗提示
static NSString * const AWEVideoPageParamNonWiFiAlert = @"show_wifi_alert";

#define IESVideoPlayerTypeSpecify [[NSUserDefaults standardUserDefaults] integerForKey:@"kSSCommonLogicHTSVideoPlayerTypeKey"]
