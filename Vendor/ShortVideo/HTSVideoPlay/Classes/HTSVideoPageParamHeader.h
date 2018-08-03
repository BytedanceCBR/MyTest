//
//  HTSVideoPageParamHeader.h
//  LiveStreaming
//
//  Created by SongLi.02 on 24/10/2016.
//  Copyright © 2016 Bytedance. All rights reserved.
//

#pragma once
#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, HTSVideoFollowGuideAction)
{
    /// 视频页关注引导关闭
    HTSVideoFollowGuideNone = 0,
    /// 视频页点赞触发关注引导
    HTSVideoFollowGuideAfterLike = 1,
    /// 视频页播放完成触发关注引导
    HTSVideoFollowGuideAfterPlay = 2,
};

/// 视频Id
static NSString * const HTSVideoPageParamVideoId = @"video_id";

/// 视频model
static NSString * const HTSVideoPageParamVideoModel = @"video_model";

/// 视频页面的来源
static NSString * const HTSVideoPageParamSource = @"source_from";

/// request_id
static NSString * const HTSVideoPageParamRequestId = @"request_id";

/// 关注动画时机
static NSString * const HTSVideoPageParamFollowGuide = @"follow_guide";

/// 视频model json string
static NSString * const HTSVideoPageParamVideoModelDict = @"video_model_dict";

/// 返场背景 3张图和frame key: "topView" "middleView" "bottomView" "cellFrame"
static NSString * const HTSVideoPageParamTransition = @"transtion_param";

/// 显示非WiFi 弹窗提示
static NSString * const HTSVideoPageParamNonWiFiAlert = @"show_wifi_alert";

/// enter_from
static NSString * const HTSVideoPageParamEnterFrom = @"enter_from";

/// card_id
static NSString * const HTSVideoPageParamCardID = @"card_id";

/// category_name
static NSString * const HTSVideoPageParamCategoryName = @"category_name";

/// card_position
static NSString * const HTSVideoPageParamCardPosition = @"card_position";

/// group_source
static NSString * const HTSVideoPageParamGroupSource = @"group_source";

/// user_id
static NSString * const HTSVideoPageParamUserID = @"user_id";

/// group_id
static NSString * const HTSVideoPageParamGroupID = @"group_id";

static NSString * const HTSVideoListFetchManager = @"list_manager";

static NSString * const HTSVideoDetailExitManager = @"exit_manager";

static NSString * const TSVDetailPushFromProfileVC = @"push_from_profile_vc";
