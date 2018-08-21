//
//  VideoTitleBarButton.h
//  Video
//
//  Created by 于 天航 on 12-7-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum VideoTitleBarButtonType {
    VideoTitleBarButtonTypeLeftNormalNarrow,
    VideoTitleBarButtonTypeLeftNormalBoard,
    VideoTitleBarButtonTypeRightNormalNarrow,
    VideoTitleBarButtonTypeLeftBack,
    VideoTitleBarButtonTypeRefresh
} VideoTitleBarButtonType;

@interface VideoTitleBarButton : UIButton

+ (VideoTitleBarButton *)buttonWithType:(VideoTitleBarButtonType)type;

@end
