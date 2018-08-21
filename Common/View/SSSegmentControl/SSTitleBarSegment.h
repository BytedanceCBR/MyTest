//
//  VideoTitleBarSegment.h
//  Video
//
//  Created by 于 天航 on 12-7-30.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import "SSSegment.h"

typedef enum {
    SSTitleBarSegmentTypeLeft,
    SSTitleBarSegmentTypeMiddle,
    SSTitleBarSegmentTypeRight,
    SSTitleBarSegmentTypeSubtitleLeft,
    SSTitleBarSegmentTypeSubtitleMiddle,
    SSTitleBarSegmentTypeSubtitleRight
} SSTitleBarSegmentType;


@class SSTitleBarSegment;

@protocol SSTitleBarSegmentDelegate <NSObject>
@optional
- (void)titleBarSegment:(SSTitleBarSegment*)segment sizeToChange:(CGSize)tSize;
@end


@interface SSTitleBarSegment : SSSegment {
    SSTitleBarSegmentType _type;
    UILabel *_subTitleLabel;
}

@property (nonatomic, assign) id<SSTitleBarSegmentDelegate> delegate;
@property (nonatomic, retain, readonly) UILabel *subTitleLabel;

- (id)initWithFrame:(CGRect)frame type:(SSTitleBarSegmentType)type;
- (void)setType:(SSTitleBarSegmentType)type;
- (void)setSubtitle:(NSString *)subTitle;
- (void)refreshUI;

@end
