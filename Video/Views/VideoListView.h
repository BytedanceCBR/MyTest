//
//  VideoListView.h
//  Video
//
//  Created by 于 天航 on 12-8-10.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSViewBase.h"

@interface VideoListView : SSViewBase

@property (nonatomic, copy) NSString *trackEventName;

- (id)initWithFrame:(CGRect)frame condition:(NSDictionary *)condition;
- (void)refresh;

@end
