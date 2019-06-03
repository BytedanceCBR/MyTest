//
//  FHPostDetailViewController
//  FHHouseUGC
//
//  Created by 张元科 on 2019/6/2.
//

#import "FHPostDetailViewController.h"
#import "FHExploreDetailToolbarView.h"
#import "SSCommonLogic.h"
#import "TTUIResponderHelper.h"
#import "UIViewAdditions.h"
#import "FHCommentViewController.h"
#import "TTDeviceHelper.h"

@interface FHPostDetailViewController ()


@property (nonatomic, strong)   FHExploreDetailToolbarView       *toolbarView;
@property (nonatomic, strong)   UITableView       *tableView;

@end

@implementation FHPostDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self setupUI];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupUI {
    [self setupNaviBar];
    [self setupToolbarView];
    [self configTableView];
    [self.view addSubview:_tableView];
    CGFloat navOffset = 65;
    if (@available(iOS 11.0 , *)) {
        navOffset = 44.f + self.view.tt_safeAreaInsets.top;
    } else {
        navOffset = 65;
    }
    [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.mas_equalTo(self.view);
        make.top.mas_equalTo(self.view).offset(navOffset);
        make.bottom.mas_equalTo(self.toolbarView.mas_top);
    }];
    // 是否有评论
    
}

- (void)setupNaviBar {
    [self setupDefaultNavBar:YES];
    
}

- (void)configTableView {
    _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    if (@available(iOS 11.0 , *)) {
        _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    _tableView.estimatedRowHeight = 0;
    _tableView.estimatedSectionFooterHeight = 0;
    _tableView.estimatedSectionHeaderHeight = 0;
    //    if ([TTDeviceHelper isIPhoneXDevice]) {
    //        _tableView.contentInset = UIEdgeInsetsMake(0, 0, 34, 0);
    //    }
}

- (void)setupToolbarView {
    self.toolbarView = [[FHExploreDetailToolbarView alloc] initWithFrame:[self p_frameForToolBarView]];
    
    if ([SSCommonLogic detailNewLayoutEnabled]) {
        self.toolbarView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    }
    
    self.toolbarView.toolbarType = FHExploreDetailToolbarTypeArticleComment;
    //    self.toolbarView.backgroundColorThemeKey = kColorBackground4;
    [self.view addSubview:self.toolbarView];
    
    [self.toolbarView.collectButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.writeButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.emojiButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.commentButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.toolbarView.shareButton addTarget:self action:@selector(toolBarButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    self.toolbarView.frame = [self p_frameForToolBarView];
    self.toolbarView.hidden = NO;
    [self p_refreshToolbarView];
}

#pragma mark - Toolbar actions

- (void)toolBarButtonClicked:(id)sender
{
    //    if (sender == self.toolbarView.collectButton) {
    //        self.toolbarView.collectButton.imageView.contentMode = UIViewContentModeCenter;
    //        self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    //        self.toolbarView.collectButton.alpha = 1.f;
    //        [UIView animateWithDuration:0.1f delay:0.f options:UIViewAnimationOptionCurveEaseOut animations:^{
    //            self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(0.6f, 0.6f);
    //            self.toolbarView.collectButton.alpha = 0.f;
    //        } completion:^(BOOL finished){
    //            [self p_willChangeArticleFavoriteState];
    //            [UIView animateWithDuration:0.2f delay:0.f options:UIViewAnimationOptionCurveEaseIn animations:^{
    //                self.toolbarView.collectButton.imageView.transform = CGAffineTransformMakeScale(1.f, 1.f);
    //                self.toolbarView.collectButton.alpha = 1.f;
    //            } completion:^(BOOL finished){
    //            }];
    //        }];
    //    }
    //    else if (sender == self.toolbarView.writeButton) {
    //        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
    //            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
    //                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    //                [baseCondition setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
    //                [baseCondition setValue:@(1) forKey:@"from"];
    //                [baseCondition setValue:@(YES) forKey:@"writeComment"];
    //                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
    //                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
    //                [baseCondition setValue:self.detailModel.article forKey:@"group"]; //竟然带了article.....
    //                baseCondition;
    //            })];
    //            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
    //                [self.commentViewController tt_clearDefaultReplyCommentModel];
    //            }
    //            [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
    //            return;
    //        }
    //        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    //        [self p_sendDetailLogicTrackWithLabel:@"write_button"];
    //        TLS_LOG(@"write_button");
    //    }
    //    else if (sender == self.toolbarView.emojiButton) {
    //        if ([self.commentViewController respondsToSelector:@selector(tt_defaultReplyCommentModel)] && self.commentViewController.tt_defaultReplyCommentModel) {
    //            [self tt_commentViewController:self.commentViewController didSelectWithInfo:({
    //                NSMutableDictionary *baseCondition = [[NSMutableDictionary alloc] init];
    //                [baseCondition setValue:self.detailModel.article.groupModel forKey:@"groupModel"];
    //                [baseCondition setValue:@(1) forKey:@"from"];
    //                [baseCondition setValue:@(YES) forKey:@"writeComment"];
    //                [baseCondition setValue:self.commentViewController.tt_defaultReplyCommentModel forKey:@"commentModel"];
    //                [baseCondition setValue:@(ArticleMomentSourceTypeArticleDetail) forKey:@"sourceType"];
    //                [baseCondition setValue:self.detailModel.article forKey:@"group"]; //竟然带了article.....
    //                baseCondition;
    //            })];
    //            if ([self.commentViewController respondsToSelector:@selector(tt_clearDefaultReplyCommentModel)]) {
    //                [self.commentViewController tt_clearDefaultReplyCommentModel];
    //            }
    //            [self.toolbarView.writeButton setTitle:@"写评论" forState:UIControlStateNormal];
    //            return;
    //        }
    //        [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:YES];
    //        //        [self p_sendDetailLogicTrackWithLabel:@"write_button"];
    //        TLS_LOG(@"emoji_button");
    //        //        [self p_sendDetailTTLogV2WithEvent:@"click_write_button" eventContext:nil referContext:nil];
    //    }
    //    else if (sender == _toolbarView.commentButton) {
    //
    //        [self p_sendNatantViewVisableTrack];
    //        if ([self.detailView.detailWebView isNatantViewOnOpenStatus]) {
    //            [self p_closeNatantView];
    //        }
    //        else {
    //            [self p_openNatantView];
    //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                [[TTAuthorizeManager sharedManager].loginObj showAlertAtActionDetailComment:^{
    //
    //                    [TTAccountManager showLoginAlertWithType:TTAccountLoginAlertTitleTypeDefault source:nil completion:^(TTAccountAlertCompletionEventType type, NSString *phoneNum) {
    //                        if (type == TTAccountAlertCompletionEventTypeDone) {
    //                            if ([TTAccountManager isLogin]) {
    //                                [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    //                            }
    //                        } else if (type == TTAccountAlertCompletionEventTypeTip) {
    //                            [TTAccountManager presentQuickLoginFromVC:[TTUIResponderHelper topNavigationControllerFor:self] type:TTAccountLoginDialogTitleTypeDefault source:nil completion:^(TTAccountLoginState state) {
    //
    //                            }];
    //                        }
    //                    }];
    //                }];
    //            });
    //
    //            //added 5.3 无评论时引导用户发评论
    //            //与新版浮层动画冲突.延迟到0.6s执行
    //            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(([self.detailView.detailWebView isNewWebviewContainer]? 0.6: 0.3) * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
    //                if (!self.detailModel.article.commentCount) {
    //                    [self p_willOpenWriteCommentViewWithReservedText:nil switchToEmojiInput:NO];
    //                }
    //            });
    //
    //            //added5.7:评论较少或无评论时，点击评论按钮弹起浮层时不会走scrollDidScroll，此处需强制调用一次检查浮层诸item是否需要发送show事件
    //            [self.natantContainerView sendNatantItemsShowEventWithContentOffset:0 isScrollUp:YES shouldSendShowTrack:YES];
    //        }
    //    }
    //    else if (sender == _toolbarView.shareButton) {
    //        [self p_willShowSharePannel];
    //    }
}

- (void)p_refreshToolbarView
{
    // add by zyk
    //    self.toolbarView.collectButton.selected = self.detailModel.article.userRepined;
    //    self.toolbarView.commentBadgeValue = [@(self.detailModel.article.commentCount) stringValue];
}

- (CGRect)p_frameForToolBarView
{
    self.toolbarView.height = FHExploreDetailGetToolbarHeight() + [TTUIResponderHelper mainWindow].tt_safeAreaInsets.bottom;
    return CGRectMake(0, self.view.height - self.toolbarView.height, self.view.width, self.toolbarView.height);
    
    //    CGFloat toolbarOriginY = [self p_frameForDetailView].size.height - self.toolbarView.height;
    //    if ([TTDeviceHelper isPadDevice]) {
    //        CGSize windowSize = [TTUIResponderHelper windowSize];
    //        return CGRectMake(0, toolbarOriginY, windowSize.width, self.toolbarView.height);
    //    }
    //    else {
    //        return CGRectMake(0, [self p_contentVisableRect].size.height, [self p_frameForDetailView].size.width, self.toolbarView.height);
    //    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    [self dismissSelf];
}

- (void)dismissSelf
{
    if (self.navigationController.viewControllers.count>1) {
        NSArray *viewControllers = self.navigationController.viewControllers;
        if (viewControllers && viewControllers.count > 1) {
            [self.navigationController popViewControllerAnimated:YES];
        }
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

@end
