//
//  SSImageAlertView.h
//  Essay
//
//  Created by Dianwei on 13-10-20.
//  Copyright (c) 2013年 Bytedance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppAlertModel.h"

@class SSImageAlertView;
@protocol SSImageAlertViewDelegate <NSObject>
- (void)imageAlertView:(SSImageAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;

@end

@interface SSImageAlertView : UIView
@property(nonatomic, retain) AppAlertModel *alertModel;
@property(nonatomic, weak) NSObject<SSImageAlertViewDelegate> *delegate;
- (id)init;
- (void)show;
- (void)hide;
@end
