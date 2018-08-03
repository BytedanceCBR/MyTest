//
//  VideoThumbView.h
//  Video
//
//  Created by Tianhang Yu on 12-7-25.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoData.h"

typedef enum {
    VideoThumbViewTypeList,
    VideoThumbViewTypeDetail
} VideoThumbViewType;

@interface VideoThumbView : UIView

@property (nonatomic, retain) VideoData *videoData;
@property (nonatomic, copy) NSString *trackEventName;

- (id)initWithFrame:(CGRect)frame type:(VideoThumbViewType)type;
- (void)refreshUI;

@end
