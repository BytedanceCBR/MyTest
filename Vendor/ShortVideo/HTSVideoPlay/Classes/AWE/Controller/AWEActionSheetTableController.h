//
//  TTActionSheetTableController.h
//  Article
//
//  Created by zhaoqin on 8/27/16.
//
//

#import <UIKit/UIKit.h>
#import "AWEActionSheetConst.h"

@class AWEActionSheetModel;
@class AWEVideoCommentDataManager;

@interface AWEActionSheetTableController : UIViewController
@property (nonatomic, strong) AWEActionSheetModel *model;
@property (nonatomic, assign) CGFloat viewHeight;//当前页面的高度，在AWEActionSheetAnimated中执行动画用到
@property (nonatomic, strong) AWEVideoCommentDataManager *manager;
@property (nonatomic, strong) NSString *reportType;
@property (nonatomic, strong) void(^trackBlock)();
@end
