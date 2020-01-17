//
//  VVeboImageView.h
//  vvebo
//
//  Created by Johnil on 14-3-6.
//  Copyright (c) 2014年 Johnil. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VVeboImage.h"

typedef void(^SSImagePlayHandler)(BOOL completion);

@interface VVeboImageView : UIImageView

/// add By jiangting 如果不循环，则停留在最后一帧
@property (nonatomic, assign) BOOL repeats;
/// delay 之后播放
@property (nonatomic, assign) BOOL delayDuration;

@property (nonatomic, copy) SSImagePlayHandler   completionHandler;

@property (nonatomic, strong) VVeboImage *gifImage;

@property (nonatomic,assign) NSInteger currentPlayIndex;

@end
