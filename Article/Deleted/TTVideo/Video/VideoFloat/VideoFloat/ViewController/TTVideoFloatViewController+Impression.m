//
//  TTVideoFloatViewController+Impression.m
//  Article
//
//  Created by panxiang on 16/7/21.
//
//

#import "TTVideoFloatViewController+Impression.h"
#import "TTVideoFloatCell.h"
#import <objc/runtime.h>

static NSInteger const vaildStayPageMinInterval = 1;
static NSInteger const vaildStayPageMaxInterval = MAXFLOAT;

#define kPageAssociatedCellPage @"kPageAssociatedCellPage"

@interface TTVideoFloatStayPageDelegate : NSObject <FRPageStayManagerDelegate>
@property (nonatomic, strong) Article *article;
@property (nonatomic, assign) BOOL sendTrack;
@end

@implementation TTVideoFloatStayPageDelegate

- (void)pageStayRecorderWithTimeInterval:(int64_t)timeInterval pageDisappearType:(FRPageDisappearType)pageDisappearType
{
    if ((timeInterval >= vaildStayPageMinInterval && timeInterval <= vaildStayPageMaxInterval) && self.sendTrack) {
//        wrapperTrackEventWithCustomKeys(@"stay_page", @"click_float_last", [NSString stringWithFormat:@"%lld",timeInterval], nil, [TTVideoFloatViewController baseExtraWithArticle:self.article]);
    }
}

@end


@implementation TTVideoFloatViewController (Impression)

- (TTVideoFloatStayPageDelegate *)stayCellPage
{
    TTVideoFloatStayPageDelegate *stayPageDelegate = objc_getAssociatedObject(self, kPageAssociatedCellPage);
    return stayPageDelegate;
}

- (void)impressionDealloc
{
    [self leaverPageStay];
    [[SSImpressionManager shareInstance] removeRegist:self];
    [self tt_logBack];
}

- (void)tt_logBack
{
    wrapperTrackEventWithCustomKeys(@"video_float", @"close", self.detailModel.article.groupModel.groupID, nil, nil);

}

- (void)tt_logEnter
{
    wrapperTrackEventWithCustomKeys(@"video_float", @"enter", self.detailModel.article.groupModel.groupID, nil, nil);
}

- (void)tt_logGoDetail
{
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setValue:self.detailModel.adID.stringValue forKey:@"ext_value"];
    [dic setValue:self.detailModel.article.groupModel.itemID forKey:@"item_id"];
    BOOL hasZzComment = self.detailModel.article.zzComments.count > 0;
    [dic setValue:@(hasZzComment?1:0) forKey:@"has_zz_comment"];
    if (hasZzComment) {
        [dic setValue:self.detailModel.article.firstZzCommentMediaId forKey:@"mid"];
    }
    wrapperTrackEventWithCustomKeys(@"go_detail", self.detailModel.clickLabel, self.detailModel.article.groupModel.groupID, nil, dic);

}

- (void)impressionViewDidLoad
{
//    [self tt_logGoDetail];
    [self tt_logEnter];
    [[SSImpressionManager shareInstance] addRegist:self];
}

- (void)leaverPageStay
{
    [[FRPageStayManager sharePageStayManager] leavePageStayWithPage:self];
    [[FRPageStayManager sharePageStayManager] endPageStayWithPage:self];
}

- (void)expression_setIsViewAppear:(BOOL)isViewAppear {

    Article *article = self.toPlayCell.cellEntity.article;
    if (!article) {
        article = self.detailModel.article;
    }

    if (isViewAppear) {
        [[FRPageStayManager sharePageStayManager] leavePageStayWithPage:self];
        [[FRPageStayManager sharePageStayManager] endPageStayWithPage:self];
        [[FRPageStayManager sharePageStayManager] startPageStayWithPage:self];
        [[FRPageStayManager sharePageStayManager] enterPageStayWithPage:self];
        if (self.toPlayCell) {
            [self startCellStayWithArticle:article];
        }
    }
    else
    {
        [[FRPageStayManager sharePageStayManager] leavePageStayWithPage:self];
        [[FRPageStayManager sharePageStayManager] endPageStayWithPage:self];
        [self endCellStay:NO];
    }
    
    if (self.isViewAppear != isViewAppear) {
        if (isViewAppear) {
            [[SSImpressionManager shareInstance] recordFloatListImpressionKeyName:[self impressionKeyName]
                                                                        groupType:[self impressionType]
                                                                           itemID:article.itemID
                                                                           status:SSImpressionStatusRecording
                                                                         userInfo:nil];
        }else {
            [[SSImpressionManager shareInstance] leaveVideoFloatListForKeyName:[self impressionKeyName]
                                                                     groupType:[self impressionType]];
        }
    }
    self.isViewAppear = isViewAppear;
}

- (TTVideoFloatStayPageDelegate *)stayPageDelegate
{
    TTVideoFloatStayPageDelegate *stayPageDelegate = objc_getAssociatedObject(self, kPageAssociatedCellPage);
    return stayPageDelegate;
}

- (void)endCellStay:(BOOL)sendTrack
{
    TTVideoFloatStayPageDelegate *stayPageDelegate = [self stayPageDelegate];
    if ([stayPageDelegate isKindOfClass:[TTVideoFloatStayPageDelegate class]]) {
        stayPageDelegate.sendTrack = sendTrack;
        [[FRPageStayManager sharePageStayManager] leavePageStayWithPage:stayPageDelegate];
        [[FRPageStayManager sharePageStayManager] endPageStayWithPage:stayPageDelegate];
    }
}

- (void)startCellStayWithArticle:(Article *)article
{
    TTVideoFloatStayPageDelegate *stayPageDelegate = [[TTVideoFloatStayPageDelegate alloc] init];
    stayPageDelegate.article = article;
    objc_setAssociatedObject(self, kPageAssociatedCellPage, stayPageDelegate, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[FRPageStayManager sharePageStayManager] startPageStayWithPage:stayPageDelegate];
    [[FRPageStayManager sharePageStayManager] enterPageStayWithPage:stayPageDelegate];

}

- (void)expression_tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTVideoFloatCell *floatCell = (TTVideoFloatCell *)cell;
    Article *article = floatCell.cellEntity.article;
    SSImpressionStatus status = SSImpressionStatusSuspend;
    if (self.isViewAppear) {
        status = SSImpressionStatusRecording;
    }
    
    [[SSImpressionManager shareInstance] recordFloatListImpressionKeyName:[self impressionKeyName]
                                                                 groupType:[self impressionType]
                                                                  itemID:article.itemID
                                                                    status:status
                                                                  userInfo:nil];
    
    [self startCellStayWithArticle:article];
}

- (void)expression_tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    TTVideoFloatCell *floatCell = (TTVideoFloatCell *)cell;
    Article *article = floatCell.cellEntity.article;
    [[SSImpressionManager shareInstance] recordFloatListImpressionKeyName:[self impressionKeyName]
                                                                groupType:[self impressionType]
                                                                   itemID:article.itemID
                                                                   status:SSImpressionStatusEnd
                                                                 userInfo:nil];
    [self endCellStay:NO];
}

#pragma mark - SSImpressionProtocol

- (NSString *)impressionKeyName {
    return self.detailModel.article.groupModel.groupID;
}

- (SSImpressionGroupType)impressionType {
    return SSImpressionGroupTypeVideoFloat;
}

- (void)needRerecordImpressions {
    for (TTVideoFloatCell * cell in [self.tableView visibleCells]) {
        Article *article = cell.cellEntity.article;
        SSImpressionStatus state = SSImpressionStatusSuspend;
        if (self.isViewAppear) {
            state = SSImpressionStatusRecording;
        }
        [[SSImpressionManager shareInstance] recordFloatListImpressionKeyName:[self impressionKeyName]
                                                                    groupType:[self impressionType]
                                                                       itemID:article.itemID
                                                                       status:state
                                                                     userInfo:nil];
    }
}

#pragma mark - FRPageStayManagerDelegate

- (void)pageStayRecorderWithTimeInterval:(int64_t)timeInterval pageDisappearType:(FRPageDisappearType)pageDisappearType
{
    if (!isEmptyString(self.detailModel.article.groupModel.groupID) && (timeInterval >= vaildStayPageMinInterval && timeInterval <= vaildStayPageMaxInterval)) {
        //业务统计打点
        if (timeInterval >= vaildStayPageMinInterval && timeInterval <= MAXFLOAT) {
            wrapperTrackEventWithCustomKeys(@"stay_category", @"video_float", [NSString stringWithFormat:@"%lld",timeInterval], nil, [[self class] baseExtraWithArticle:self.detailModel.article]);
        }
    }
}

@end
