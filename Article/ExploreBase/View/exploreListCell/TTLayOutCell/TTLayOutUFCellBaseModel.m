//
//  TTLayOutU11CellBaseModel.m
//  Article
//
//  Created by 王双华 on 16/11/3.
//
//

#import "TTLayOutUFCellBaseModel.h"
//#import "TTThreadCellHelper.h"
#import "FriendDataManager.h"
#import "TTRecommendUserCell.h"
#import "NSDictionary+TTAdditions.h"

@interface TTLayOutUFCellBaseModel ()
@end

@implementation TTLayOutUFCellBaseModel

- (CGFloat)heightForHeaderInfoRegionInTwoLinesWithTop:(CGFloat)top needLayoutDislike:(BOOL)layoutDislike {
    CGFloat height = [super heightForHeaderInfoRegionInTwoLinesWithTop:top needLayoutDislike:layoutDislike];
    if (self.orderedData.cellLayOut.isExpand) {
        CGFloat collectionHeight = [TTRecommendUserCellView heightForData:self.orderedData cellWidth:self.cellWidth listType:self.listType slice:YES] ;
        self.recommendCardsFrame = CGRectMake(0, height + 6, self.cellWidth, collectionHeight);
        height += collectionHeight;
    } else {
        self.recommendCardsFrame = CGRectMake(0, height + 6, self.cellWidth, 0);
    }
    return height;
}


- (void)calculateAllFrame
{
    self.originX = kPaddingLeft();
    CGFloat top = kPaddingUFTop();
    self.containWidth = self.cellWidth - kPaddingLeft() - kPaddingRight();
    CGFloat height = top + [self heightForCellContentWithTop:top];
    self.cellCacheHeight = height + [self heightForTopSeparateViewWithTop:0.f] + [self heightForBottomSeparateViewWithTop:height];
    [self calculateBottomLineFrame];
}

- (void)calculateNeedUpdateFrame
{
    //
}

- (void)calculateBottomLineFrame
{
    if ([self.orderedData isInCard]){
        self.bottomLineViewFrame = CGRectMake(0, self.cellCacheHeight - [TTDeviceHelper ssOnePixel], self.cellWidth, [TTDeviceHelper ssOnePixel]);
        self.bottomLineViewHidden = NO;
    }
}

- (CGFloat)heightForTopSeparateViewWithTop:(CGFloat)top
{
    if ([self.orderedData hasTopPadding]) {
        self.topRectFrame = CGRectMake(0, 0, self.cellWidth, kUFSeprateViewHeight());
        self.topRectHidden = NO;
        return kUFSeprateViewHeight();
    }
    return 0.f;
}

- (CGFloat)heightForBottomSeparateViewWithTop:(CGFloat)top
{
    if ([self.orderedData hasTopPadding]) {
        self.bottomRectFrame = CGRectMake(0,top, self.cellWidth, kUFSeprateViewHeight());
        self.bottomRectHidden = NO;
        return kUFSeprateViewHeight();
    }
    return 0.f;
}

- (CGFloat)heightForCellContentWithTop:(CGFloat)top
{
    return 0;//implement in subclass
}

- (CGFloat)heightForFunctionRegionWithTop:(CGFloat)top
{
    CGFloat left = self.originX;
    
    self.digButtonImageName = @"c_comment_like_icon";
    self.digButtonSelectedImageName = @"c_comment_like_press_icon";
    self.digButtonTextColorThemeKey = kColorText3;
    self.digButtonFontSize = 12.f;
    self.digButtonContentInsets = UIEdgeInsetsMake(0, 0, 0, 3);
    self.digButtonTitleInsets = UIEdgeInsetsMake(0, 3, 0, -3);
    CGRect digButtonFrame = CGRectMake(left, top, 68, kUFFunctionViewHeight());
    self.digButtonFrame = digButtonFrame;
    self.digButtonHidden = NO;
    left += 68;
    
    self.commentButtonImageName = @"c_comment_icon";
    self.commentButtonTextColorThemeKey = kColorText3;
    self.commentButtonFontSize = 12.f;
    self.commentButtonContentInsets = UIEdgeInsetsMake(0, 0, 0, 3);
    self.commentButtonTitleInsets = UIEdgeInsetsMake(0, 3, 0, -3);
    CGRect commentButtonFrame = CGRectMake(left, top, 68, kUFFunctionViewHeight());
    self.commentButtonFrame = commentButtonFrame;
    self.commentButtonHidden = NO;

    CGFloat unInterestedBtnX = 0,unInterestedBtnY = 0;
    CGFloat unInterestedBtnWidth = 60;
    CGFloat unInterestedBtnHeight = 44;
    unInterestedBtnX = ceilf(self.originX + self.containWidth - kCellUninterestedButtonWidth / 2 - unInterestedBtnWidth / 2);
    unInterestedBtnY = ceilf(top + kUFFunctionViewHeight() / 2 - unInterestedBtnHeight / 2);
    CGRect unInterestedBtnFrame = CGRectMake(unInterestedBtnX, unInterestedBtnY, unInterestedBtnWidth, unInterestedBtnHeight);
    self.unInterestedButtonFrame = unInterestedBtnFrame;
//    if (self.listType == ExploreOrderedDataListTypeFavorite ||
//        self.listType == ExploreOrderedDataListTypeReadHistory ||
//        self.listType == ExploreOrderedDataListTypePushHistory ||
//        (self.orderedData.showDislike && ![self.orderedData.showDislike boolValue])){
//        self.unInterestedButtonHidden = YES;
//    }
//    else{
//        self.unInterestedButtonHidden = NO;
//    }
    self.unInterestedButtonHidden = YES;
    return kUFFunctionViewHeight();
}


// 10赞 21评论 300阅读
- (CGFloat)heightForActionLabelRegionWithTop:(CGFloat)top
{
    CGFloat left = self.originX;
    NSString *actionInfoStr = [TTLayOutCellDataHelper getInfoStringForUFCellWithOrderedData:self.orderedData];
    
    if (actionInfoStr.length == 0) { //没有任何显示的内容
        self.infoLabelHidden = YES;
        
        self.actionSepLineFrame = CGRectMake(0, top + kUFS1PaddingPicBottom(), self.cellWidth, [TTDeviceHelper ssOnePixel]);
        self.actionSepLineHidden = NO;
    } else {
        NSString *fixedActionInfoStr = [actionInfoStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.infoLabelFrame = CGRectMake(left, top + kUFS1PaddingPicBottom(), self.containWidth, kCellTypeLabelHeight);
        self.infoLabelFontSize = kCellInfoLabelFontSize;
        self.infoLabelTextColorThemeKey = kCellInfoLabelTextColor;
        self.infoLabelHidden = NO;
        self.infoLabelStr = fixedActionInfoStr;
        
        self.actionSepLineFrame = CGRectMake(0, top + kUFS1PaddingPicBottom() + kCellTypeLabelHeight + kUFS1PaddingPicBottom(), self.cellWidth, [TTDeviceHelper ssOnePixel]);
        self.actionSepLineHidden = NO;
    }
    
    return kUFS1PaddingPicBottom() + (self.infoLabelHidden? 0: kCellTypeLabelHeight + kUFS1PaddingPicBottom()) + [TTDeviceHelper ssOnePixel];
}

// 点赞按钮  评论按钮
- (CGFloat)heightForActionButtonRegionWithTop:(CGFloat)top
{
    CGFloat actionNumber = 3;
    if ([TTDeviceHelper isPadDevice]) {
        actionNumber = 2;
    }
    CGFloat height = 36;
    CGFloat buttonWidth = self.cellWidth / actionNumber;
    CGFloat imageWidth = 24;
    CGFloat titleLeftPadding = 5;
    CGFloat padding = self.originX;
    
    NSString *digStr = [TTLayOutCellDataHelper getDigNumberStringWithOrderedData:self.orderedData];
    self.digButtonImageName = @"like_old_feed";
    self.digButtonSelectedImageName = @"like_old_feed_press";
    self.digButtonTextColorThemeKey = kColorText2;
    self.digButtonFontSize = 12.f;
    self.needMultiDiggAnimation = YES;
    
    CGSize digStrSize = [digStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:self.digButtonFontSize]}];
    digStrSize = CGSizeMake(ceil(digStrSize.width), ceil(digStrSize.height));
    CGFloat digButtonContentWidth = imageWidth + titleLeftPadding + digStrSize.width;
    CGFloat left = 0;
    CGRect digButtonFrame = CGRectMake(left, top, buttonWidth, height);
    
    CGFloat digInsetLeft = padding + ceil((buttonWidth - padding - digButtonContentWidth) / 2);
    
    self.digButtonContentInsets = UIEdgeInsetsMake(0, digInsetLeft, 0, 0);
    self.digButtonTitleInsets = UIEdgeInsetsMake(0, titleLeftPadding, 0, - titleLeftPadding);
    self.digButtonFrame = digButtonFrame;
    self.digButtonHidden = NO;
    
    NSString *comStr = [TTLayOutCellDataHelper getCommentNumberStringWithOrderedData:self.orderedData];
    self.commentButtonImageName = @"comment_feed";
    self.commentButtonTextColorThemeKey = kColorText2;
    self.commentButtonFontSize = 12.f;
    
    CGSize comStrSize = [comStr sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:self.commentButtonFontSize]}];
    comStrSize = CGSizeMake(ceil(comStrSize.width), ceil(comStrSize.height));
    CGFloat comButtonContentWidth = imageWidth + titleLeftPadding + comStrSize.width;
    
    left = buttonWidth;
    
    CGRect commentButtonFrame = CGRectMake(left, top, buttonWidth, height);
    CGFloat comInsetLeft = ceil((buttonWidth - comButtonContentWidth) / 2);
    if ([TTDeviceHelper isPadDevice]) {
        comInsetLeft = ceil((buttonWidth - padding - comButtonContentWidth) / 2);
    }
    
    self.commentButtonContentInsets = UIEdgeInsetsMake(0, comInsetLeft, 0, 0);
    self.commentButtonTitleInsets = UIEdgeInsetsMake(0, titleLeftPadding, 0, - titleLeftPadding);
    self.commentButtonFrame = commentButtonFrame;
    self.commentButtonHidden = NO;
    
    
    if (![TTDeviceHelper isPadDevice]) {
        NSString * forwardStr = [TTLayOutCellDataHelper getForwardStringWithOrderedData:self.orderedData];
        self.forwardButtonImageName = @"feed_share";
        self.forwardButtonTextColorThemeKey = kColorText2;
        self.forwardButtonFontSize = 12.f;
        CGSize forwardSize = [forwardStr sizeWithAttributes:@{NSFontAttributeName:[UIFont tt_fontOfSize:self.forwardButtonFontSize]}];
        forwardSize = CGSizeMake(ceil(forwardSize.width), ceil(forwardSize.height));
        CGFloat forwardButtonContentWidth = imageWidth + titleLeftPadding + forwardSize.width;
        left = buttonWidth*2;
        CGRect forwardButtonFrame = CGRectMake(left, top, buttonWidth, height);
        CGFloat forwardInsetLeft = ceil((buttonWidth - padding - forwardButtonContentWidth)/2);
        self.forwardButtonContentInsets = UIEdgeInsetsMake(0, forwardInsetLeft, 0, 0);
        self.forwardButtonTitleInsets = UIEdgeInsetsMake(0, titleLeftPadding, 0, -titleLeftPadding);
        self.forwardButtonFrame = forwardButtonFrame;
        self.forwardButtonHidden = NO;
    }else {
        self.forwardButtonHidden = YES;
    }
    
    //非iPad，交换点赞和转发位置
    if (![TTDeviceHelper isPadDevice]) {
        CGRect tmpRect = self.digButtonFrame;
        self.digButtonFrame = self.forwardButtonFrame;
        self.forwardButtonFrame = tmpRect;
        
        UIEdgeInsets tmpInsets = self.digButtonContentInsets;
        self.digButtonContentInsets = self.forwardButtonContentInsets;
        self.forwardButtonContentInsets = tmpInsets;
        
        tmpInsets = self.digButtonTitleInsets;
        self.digButtonTitleInsets = self.forwardButtonTitleInsets;
        self.forwardButtonTitleInsets = tmpInsets;
    }
    
    return height;
}

- (TTFollowThemeButton *)generateFollowButton {
    return [self followButton:self.orderedData];
}

- (TTFollowThemeButton *)followButton:(ExploreOrderedData *)orderedData {
    TTUnfollowedType unFollowType = TTUnfollowedType101;
    TTFollowedType followType = TTFollowedType101;
    TTFollowedMutualType mutualType = TTFollowedMutualType101;
    if ([orderedData.followButtonStyle integerValue] == 1) {
        unFollowType = TTUnfollowedType101;
        followType = TTFollowedType101;
        mutualType = TTFollowedMutualType101;
    } else {
        unFollowType = TTUnfollowedType102;
        followType = TTFollowedType102;
        mutualType = TTFollowedMutualType102;
    }
    TTFollowThemeButton* button = [[TTFollowThemeButton alloc] initWithUnfollowedType:unFollowType followedType:followType followedMutualType:mutualType];
    return button;
}

@end
