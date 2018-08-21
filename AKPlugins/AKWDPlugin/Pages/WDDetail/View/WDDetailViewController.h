//
//  WDDetailViewController.h
//  Article
//
//  Created by 延晋 张 on 16/4/11.
//
//

#import "SSViewControllerBase.h"
#import "TTDetailViewController.h"
#import <AKCommentPlugin/TTCommentWriteManager.h>
#import <AKCommentPlugin/TTCommentViewControllerProtocol.h>

/*
 * 6.30 发现加了两个DetailView，稍后去别的分支看一下
 * 7.2  滑动查看下一个回答的提示相关逻辑添加到本类中,规则为：每天展示一次，直到用户手动滑动查看下一个
 * 7.4  添加一个逻辑：展示出来再去请求infomation接口
 * 7.18 修复一些埋点时机错误bug
 */

@protocol WDDetailViewControllerDelegate <NSObject>

- (void)wd_detailViewControllerAfterDeleteAnswer;
- (void)wd_detailViewControllerShowSlideHelperView;
- (void)wd_detailViewControllerShowIndicatorPolicyView;
- (void)wd_detailViewControllerDidScroll:(UIScrollView *)scrollView index:(NSInteger)index;
- (void)wd_detailViewControllerWriteCommentWithReservedText:(NSString *)reservedText;
- (void)wd_detailViewControllerWriteCommentWithCondition:(NSDictionary *)condition;
- (void)wd_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info;

@end

@class WDDetailView;
@class WDDetailModel;
@class WDDetailNatantViewModel;

@interface WDDetailViewController : SSViewControllerBase

@property (nonatomic, strong, readonly) WDDetailView *detailView;

@property (nonatomic, strong, readonly) WDDetailNatantViewModel *natantViewModel;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, weak) id<WDDetailViewControllerDelegate>wdDelegate;

- (instancetype)initWithDetailModel:(WDDetailModel *)detailModel;

- (void)viewStartDisplay;

- (void)viewEndDisplay;

- (void)viewWillDisappear;

- (void)viewDidDisappear;

- (void)viewWillReappear;

- (void)viewDidReappear;

- (void)viewEnterBackground;

- (void)viewEnterForeground;

- (void)reloadData;

- (void)loadInfomationIfNeeded;

- (void)commentCountButtonTapped;

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData;

- (BOOL)banEmojiInput;

- (NSString *)writeCommentViewPlaceholder;

@end
