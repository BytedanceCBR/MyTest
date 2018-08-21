//
//  TTActionSheetTextController.h
//  Article
//
//  Created by zhaoqin on 8/30/16.
//
//

#import <UIKit/UIKit.h>
#import "AWEActionSheetConst.h"

@class AWEVideoCommentDataManager;

@interface AWEActionSheetTextController : UIViewController
@property (nonatomic, strong) NSString *type;
@property (nonatomic, assign) CGFloat viewHeight;//当前页面的高度，在TTActionSheetAnimated中执行动画用到
@property (nonatomic, strong) AWEVideoCommentDataManager *manager;

@end
