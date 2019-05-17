//
//  TTArticleDetailViewController+Report.h
//  Article
//
//  Created by muhuai on 2017/7/31.
//
//

#import <Foundation/Foundation.h>
#import "TTArticleDetailViewController.h"
#import <TTPlatformUIModel/TTActionSheetController.h>
#import "TTDislikeContainer.h"

@interface TTArticleDetailViewController (Report)
//详情页dislike及report字典
@property (nonatomic, copy) NSDictionary *dislikeDictionary;
@property (nonatomic, strong) TTActionSheetController *actionSheetController;

//重构后的dislike
@property (nonatomic, strong) TTDislikeContainer *dislikeContainer;
@property (nonatomic, assign) BOOL shouldSentDislikeNotification;

- (void)report_dealloc;

- (void)report_showReportOnNatantView:(NSString *)style source:(TTActionSheetSourceType)source trackSource:(NSString *)trackSource;

- (void)report_showReportOnSharePannel;

//点击右上角分享面板的 举报操作
- (void)report_showReportOnTopSharePannel;
@end
