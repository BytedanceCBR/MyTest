//
//  WDImageBoxView.h
//  wenda
//
//  Created by xuzichao on 17/6/9.
//  Copyright (c) 2017年 toutiao. All rights reserved.
//

#import "SSThemed.h"

@interface WDImageBoxView : SSThemedView

@property(nonatomic,strong) NSString *umengEventStr;

@property(nonatomic,assign) int64_t threadId;

@property(nonatomic,strong) NSArray *imgModelArray;

@property(nonatomic,strong) NSArray *largeModelArray;

@property(nonatomic,assign) CGFloat preferredMaxLayoutWidth;

@property(nonatomic,assign) CGFloat halfViewSpacing;

+ (CGSize)limitedSizeWithSize:(CGSize)aSize maxLimit:(CGFloat)maxLimit;
+ (CGSize)limitedSizeForGif:(CGSize)aSize maxLimit:(CGFloat)maxlimit;

@end
