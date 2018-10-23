//
//  SSSegment.h
//  Video
//
//  Created by Tianhang Yu on 12-7-24.
//  Copyright (c) 2012年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SSSegment : UIButton {
    BOOL _checked;
}

@property (nonatomic) NSUInteger index;
@property (nonatomic) BOOL checked;

@property (nonatomic, strong) UIView *badgeView;

- (void)refreshUI;

@end
