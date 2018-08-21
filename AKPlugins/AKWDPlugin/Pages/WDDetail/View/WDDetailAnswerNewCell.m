//
//  WDDetailAnswerNewCell.m
//  Article
//
//  Created by wangqi.kaisa on 2017/6/30.
//
//

#import "WDDetailAnswerNewCell.h"
#import "WDDetailViewController.h"
#import "WDDetailModel.h"
#import "WDFetchAnswerContentHelper.h"
#import "WDDetailView.h"
#import "WDDetailViewModel.h"
#import "WDDetailAnswerEmptyView.h"
#import "WDAnswerEntity.h"

#import "TTDetailWebviewContainer.h"

#import "UIView+Refresh_ErrorHandler.h"
#import "NetworkUtilities.h"
#import <TTRoute/TTRouteDefine.h>


@interface WDDetailAnswerNewCell ()<WDDetailViewControllerDelegate, UIViewControllerErrorHandler, WDDetailAnswerEmptyViewDelegate>

@property (nonatomic, strong) WDFetchAnswerContentHelper *fetchViewModel;
@property (nonatomic, strong) WDDetailViewController *detailViewController;
@property (nonatomic, strong) WDDetailAnswerEmptyView *emptyView; // 无网络时的view
@property (nonatomic, assign) BOOL answerLoadFinished;
@property (nonatomic, assign) BOOL isDisplaying;

@end

@implementation WDDetailAnswerNewCell

- (void)dealloc {
    if (self.detailViewController) {
        [self.detailViewController.view removeFromSuperview];
        self.detailViewController.view = nil;
        self.detailViewController = nil;
    }
}

- (void)prepareForReuse {
    if (self.detailViewController) {
        [self.detailViewController.view removeFromSuperview];
        self.detailViewController.view = nil;
        self.detailViewController = nil;
    }
    
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
}

#pragma mark - public

- (void)setDetailAnswerFromDetailModel:(WDDetailModel *)detailModel {
    
    if (self.detailViewController) {
        [self.detailViewController.view removeFromSuperview];
        self.detailViewController.view = nil;
        self.detailViewController = nil;
    }
    
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
    
    self.fetchViewModel = nil;
    self.fetchViewModel.fetchContentBlock = nil;
    self.detailModel = nil;
    
    self.answerLoadFinished = YES;
    
    [self p_setDetailAnswerFromDetailModel:detailModel inside:NO];
}

- (void)setDetailAnswerRouteParamObj:(TTRouteParamObj *)paramObj {
    
    if (self.detailViewController) {
        [self.detailViewController.view removeFromSuperview];
        self.detailViewController.view = nil;
        self.detailViewController = nil;
    }
    
    if (self.emptyView) {
        [self.emptyView removeFromSuperview];
        self.emptyView = nil;
    }
    
    self.fetchViewModel = nil;
    self.fetchViewModel.fetchContentBlock = nil;
    self.detailModel = nil;
    
    self.answerLoadFinished = NO;
    
    self.fetchViewModel = [[WDFetchAnswerContentHelper alloc] initWithRouteParamObj:paramObj];
    self.detailModel = _fetchViewModel.detailModel;
    [self fetchContentFromRemoteFirstTime:YES];
}

- (void)cellStartDisplay {
    self.isDisplaying = YES;
    if (self.detailViewController) {
        [self.detailViewController viewStartDisplay];
    }
}

- (void)cellEndDisplay {
    if (!self.isDisplaying) {
        return;
    }
    self.isDisplaying = NO;
    if (self.detailViewController) {
        [self.detailViewController viewEndDisplay];
    }
}

- (void)cellWillDisappear {
    if (self.detailViewController) {
        [self.detailViewController viewWillDisappear];
    }
}

- (void)cellDidDisappear {
    if (self.detailViewController) {
        [self.detailViewController viewDidDisappear];
    }
}

- (void)cellWillReappear {
    if (self.detailViewController) {
        [self.detailViewController viewWillReappear];
    }
}

- (void)cellDidReappear {
    if (self.detailViewController) {
        [self.detailViewController viewDidReappear];
    }
}

- (void)cellEnterBackground {
    if (self.detailViewController) {
        [self.detailViewController viewEnterBackground];
    }
}

- (void)cellEnterForeground {
    if (self.detailViewController) {
        [self.detailViewController viewEnterForeground];
    }
}

- (void)loadInfomationIfNeeded {
    if (self.answerLoadFinished && self.detailViewController) {
        [self.detailViewController loadInfomationIfNeeded];
    }
}

- (double)getReadPct {
    return [self.detailViewController.detailView.detailWebView readPCTValue];
}

- (NSInteger)getPageCount {
    return [self.detailViewController.detailView.detailWebView pageCount];
}

- (NSString *)getDetailViewUserID {
    return self.detailViewController.detailView.detailViewModel.person.userID;
}


- (void)commentCountButtonTapped {
    [self.detailViewController commentCountButtonTapped];
}

- (void)commentView:(TTCommentWriteView *) commentView sucessWithCommentWriteManager:(TTCommentWriteManager *)commentWriteManager responsedData:(NSDictionary *)responseData
{
    [self.detailViewController commentView:commentView sucessWithCommentWriteManager:commentWriteManager responsedData:responseData];
}

- (BOOL)banEmojiInput
{
    return [self.detailViewController banEmojiInput];
}

- (NSString *)writeCommentViewPlaceholder
{
    return [self.detailViewController writeCommentViewPlaceholder];
}

#pragma mark - WDDetailViewControllerDelegate

- (void)wd_detailViewControllerAfterDeleteAnswer {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellAfterDeleteAnswer)]) {
        [_delegate wd_detailAnswerNewCellAfterDeleteAnswer];
    }
}

- (void)wd_detailViewControllerShowSlideHelperView {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellShowSlideHelperView)]) {
        [_delegate wd_detailAnswerNewCellShowSlideHelperView];
    }
}

- (void)wd_detailViewControllerShowIndicatorPolicyView {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellShowIndicatorPolicyView)]) {
        [_delegate wd_detailAnswerNewCellShowIndicatorPolicyView];
    }
}

- (void)wd_detailViewControllerDidScroll:(UIScrollView *)scrollView index:(NSInteger)index {
    if (index != self.index) return;
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellDidScroll:index:)]) {
        [_delegate wd_detailAnswerNewCellDidScroll:scrollView index:index];
    }
}

- (void)wd_detailViewControllerWriteCommentWithReservedText:(NSString *)reservedText {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellWriteCommentWithReservedText:)]) {
        [_delegate wd_detailAnswerNewCellWriteCommentWithReservedText:reservedText];
    }
}

- (void)wd_detailViewControllerWriteCommentWithCondition:(NSDictionary *)condition {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellWriteCommentWithCondition:)]) {
        [_delegate wd_detailAnswerNewCellWriteCommentWithCondition:condition];
    }
}

- (void)wd_commentViewController:(id<TTCommentViewControllerProtocol>)ttController didSelectWithInfo:(NSDictionary *)info
{
    if ([self.delegate respondsToSelector:@selector(wd_commentViewController:didSelectWithInfo:)]) {
        [self.delegate wd_commentViewController:ttController didSelectWithInfo:info];
    }
}

#pragma mark - UIViewControllerErrorHandler

- (BOOL)tt_hasValidateData {
    return NO;
}

#pragma mark - WDDetailAnswerEmptyViewDelegate

- (void)wd_detailAnswerEmptyViewDidScrollWithContentOffsetY:(CGFloat)offsetY {
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellDidScrollWithContentOffsetY:index:)]) {
        [_delegate wd_detailAnswerNewCellDidScrollWithContentOffsetY:offsetY index:self.index];
    }
}

- (void)wd_detailAnswerEmptyViewReconnectLoadData {
    self.emptyView.hidden = YES;
    [self fetchContentFromRemoteFirstTime:NO];
}

#pragma mark - private

- (void)fetchContentFromRemoteFirstTime:(BOOL)firstTime {
    [self tt_startUpdate];
    WeakSelf;
    [self.fetchViewModel fetchContentFromRemoteIfNeededWithComplete:^(WDFetchResultType type) {
        StrongSelf;
        if (type == WDFetchResultTypeDone) {
            [self tt_endUpdataData];
            self.fetchViewModel.detailModel.isArticleReliable = !isEmptyString(self.fetchViewModel.detailModel.answerEntity.questionTitle);
            [self p_loadContentSuccessFirstTime:firstTime];
        }
        else if (type == WDFetchResultTypeEndLoading) {
            [self tt_endUpdataData];
        }
        else {
            [self p_loadContentFailed];
        }
    }];
}

- (void)p_loadContentSuccessFirstTime:(BOOL)firstTime {
    self.answerLoadFinished = YES;
    [self p_setDetailAnswerFromDetailModel:self.fetchViewModel.detailModel inside:YES];
    if (!firstTime) {
        [self loadInfomationIfNeeded];
    }
    if (_delegate && [_delegate respondsToSelector:@selector(wd_detailAnswerNewCellAfterFetchContentSuccessFirstTime:)]) {
        [_delegate wd_detailAnswerNewCellAfterFetchContentSuccessFirstTime:firstTime];
    }
}

- (void)p_loadContentFailed {
    if (self.answerLoadFinished == YES) return;
    if (!_emptyView) {
        [self p_buildPlaceHolderView];
    }
    self.emptyView.hidden = NO;
    [self.emptyView setEmptyTypeReason:1 error:nil];
    [self tt_endUpdataData];
}

- (void)p_setDetailAnswerFromDetailModel:(WDDetailModel *)detailModel inside:(BOOL)inside {
    
    self.detailModel = detailModel;
    
    self.detailViewController = [[WDDetailViewController alloc] initWithDetailModel:_detailModel];
    self.detailViewController.view.frame = self.bounds;
    self.detailViewController.index = self.index;
    self.detailViewController.wdDelegate = self;
    [self addSubview:self.detailViewController.view];
    
    [self.detailViewController reloadData];
    
    if (self.isDisplaying) {
        [self.detailViewController viewStartDisplay];
    }
    
    if (!inside) {
        [self.detailViewController loadInfomationIfNeeded];
    }
}

- (void)p_buildPlaceHolderView {
    self.emptyView = [[WDDetailAnswerEmptyView alloc] initWithFrame:self.bounds];
    self.emptyView.delegate = self;
    self.emptyView.index = self.index;
    [self addSubview:self.emptyView];
    [self.emptyView startShow];
}

#pragma mark - get

- (WDDetailNatantViewModel *)natantViewModel {
    return self.detailViewController.natantViewModel;
}

@end
