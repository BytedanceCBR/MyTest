//
//  ArticleMomentHelper.m
//  Article
//
//  Created by Zhang Leonardo on 14-5-26.
//
//

#import "ArticleMomentHelper.h"
#import "TTRoute.h"
#import "ArticleMomentProfileViewController.h"
#import "ArticleMomentModel.h"
#import "TTStringHelper.h"
#import "TTRoute.h"


#define kMaxLineOfCommentInMomentListKey @"kMaxLineOfCommentInMomentListKey"


@implementation ArticleMomentHelper

+ (void)openGroupDetailView:(ArticleMomentModel *)model goDetailFromSource:(NewsGoDetailFromSource)fSource
{
    if ([model.group.ID longLongValue] == 0) {
        return;
    }
    NSString * fromSourceStr = [NewsDetailLogicManager articleDetailEventLabelForSource:fSource categoryID:nil];
    
    NSString * detailStr = nil;
    if (model.group.groupType == ArticleMomentGroupArticle) {
        detailStr = [NSString stringWithFormat:@"sslocal://detail?groupid=%@&gd_label=%@", model.group.ID, fromSourceStr];
    }
    else if (model.group.groupType == ArticleMomentGroupEssay) {
        detailStr = [NSString stringWithFormat:@"sslocal://essay_detail?groupid=%@&gd_label=%@", model.group.ID, fromSourceStr];
    }
    if (!isEmptyString(detailStr)) {
        [[TTRoute sharedRoute] openURLByPushViewController:[TTStringHelper URLWithURLString:detailStr]];
    }
}

+ (void)openMomentProfileView:(SSUserModel *)model navigationController:(UINavigationController *)naviController from:(NSString *)from
{
    if (isEmptyString(model.ID)) {
        return;
    }
    
    if (!naviController) {
        naviController = [TTUIResponderHelper topNavigationControllerFor:nil];
    }
    /// 判断如果是从个人主页跳转，并且又跳转到相同的个人主页
    if ([[naviController.viewControllers lastObject] isKindOfClass:[ArticleMomentProfileViewController class]]) {
        ArticleMomentProfileViewController * vc = [naviController.viewControllers lastObject];
        if ([vc.userID isEqualToString:model.ID]) {
            return;
        }
    }
    ArticleMomentProfileViewController * controller = [[ArticleMomentProfileViewController alloc] initWithUserModel:model];
    controller.from = from;
    [naviController pushViewController:controller animated:YES];
}

+ (BOOL)momentDictValid:(NSDictionary *)dict
{
    MomentListCellType cellType = [[dict objectForKey:@"cell_type"] integerValue];
    if (cellType == MomentListCellTypeMoment) {
        MomentItemType itemType = [[dict objectForKey:@"item_type"] integerValue];
        BOOL support = [self supportMomentType:itemType];
        if (!support) {
            return NO;
        }
    }
    if (cellType == MomentListCellTypeMomo) {
        
    }
    return YES;
}

+ (BOOL)supportMomentType:(MomentItemType)itemType
{
    if (itemType == MomentItemTypeArticle ||
        itemType == MomentItemTypeForum ||
        itemType == MomentItemTypeForward ||
        itemType == MomentItemTypeNoForum ||
        itemType == MomentItemTypeOnlyShowInForum) {
        return YES;
    }
    return NO;
}

+ (void)setMaxLineOfCommentInMomentList:(NSUInteger)number
{
    if (number > 2) {
        [[NSUserDefaults standardUserDefaults] setValue:@(number) forKey:kMaxLineOfCommentInMomentListKey];
        [[NSUserDefaults  standardUserDefaults] synchronize];
    }
}

+ (NSUInteger)maxLineOfCommentInMomentList
{
    NSUInteger num = [[[NSUserDefaults standardUserDefaults] objectForKey:kMaxLineOfCommentInMomentListKey] intValue];
    if (num <= 2) {
        return 9;
    }
    return num;
}


@end
