//
//  TTLayOutUGCCellBaseModel.m
//  Article
//
//  Created by 王双华 on 16/10/17.
//
//

#import "TTLayOutUGCCellBaseModel.h"


@implementation TTLayOutUGCCellBaseModel

- (void)calculateAllFrame
{
    self.originX = kPaddingLeft();
    self.originY = kPaddingTop();
    CGFloat containWidth = self.cellWidth - kPaddingLeft() - kPaddingRight();
    [self calculateFunctionViewFrameWithContainWidth:containWidth];
    [self calculateOtherFramesWithContainWidth:containWidth];
    [self calculateBottomLineFrame];
}

- (void)calculateNeedUpdateFrame
{
    if (!self.hideTimeForRightPic && self.infoBarOriginY > 0 && self.infoBarContainWidth > 0){
        [self calculateBottomLineFrame];
        [self calculateTimeLabelWithY:self.infoBarOriginY withContainWidth:self.infoBarContainWidth];
    }
}

- (void)calculateBottomLineFrame
{
    if (![self.orderedData nextCellHasTopPadding]){
        self.bottomLineViewFrame = CGRectMake(0, self.cellCacheHeight - [TTDeviceHelper ssOnePixel], self.cellWidth, [TTDeviceHelper ssOnePixel]);
        self.bottomLineViewHidden = NO;
    }
}

- (void)calculateTimeLabelWithY:(CGFloat)originY withContainWidth:(CGFloat)containWidth
{
    CGFloat x = self.originX;
    CGFloat y = originY;
    
    NSString *timesString = [TTLayOutCellDataHelper getTimeStringWithOrderedData:self.orderedData];
    if (!isEmptyString(timesString)) {
        CGSize timeSize = [timesString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kInfoViewFontSize()]}];
        timeSize = CGSizeMake(ceilf(timeSize.width), ceilf(timeSize.height));
        CGRect timeLabelFrame = CGRectMake(x + containWidth - timeSize.width, y, timeSize.width, kInfoViewHeight());
        self.timeLabelFrame = timeLabelFrame;
        
        self.timeLabelHidden = NO;
    }
    else{
        self.timeLabelHidden = YES;
    }
}

- (void)calculateFunctionViewFrameWithContainWidth:(CGFloat)containWidth
{
    CGFloat left = self.originX;
    CGFloat y = 0;
    NSString *likeString = nil;
    likeString = [TTLayOutCellDataHelper getLikeStringWithOrderedData:self.orderedData];
    if (!isEmptyString(likeString)) {
        CGRect likeLabelFrame = CGRectMake(left, self.originY, containWidth - kMoreViewSide() - kMoreViewExpand(), kLikeViewFontSize());
        y += kLikeViewFontSize() + kFunctionViewPaddingLikeToSource();
        self.likeLabelFrame = likeLabelFrame;
        self.likeLabelHidden = NO;
    }
    else{
        self.likeLabelHidden = YES;
    }
    
    CGRect sourceImageViewFrame = CGRectMake(left, self.originY + y, kSourceViewImageSide(), kSourceViewImageSide());
    self.sourceImageViewFrame = sourceImageViewFrame;
    self.sourceImageURLStr = [TTLayOutCellDataHelper getSourceImageUrlStringForUGCCellWithOrderedData:self.orderedData];
    NSString *sourceName = [TTLayOutCellDataHelper getSourceNameStringForUGCCellWithOrderedData:self.orderedData];
    if (sourceName.length >= 1) {
        self.sourceNameFirstWord = [sourceName substringToIndex:1];
    }
    else{
        self.sourceNameFirstWord = @"佚";
    }
    self.sourceImageUserInteractionEnabled = YES;
    self.sourceNameFirstWordFontSize = [TTDeviceUIUtils tt_fontSize:12];
    self.sourceImageViewHidden = NO;
    left += kSourceViewImageSide() + kFunctionViewPaddingSourceImageToSource();
    
    NSString *sourceString = [TTLayOutCellDataHelper getSourceNameStringForUGCCellWithOrderedData:self.orderedData];
    CGSize sourceSize = [sourceString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kSourceViewFontSize()]}];
    sourceSize = CGSizeMake(ceilf(sourceSize.width), ceilf(sourceSize.height));
    CGFloat sourceLabelOriginY = self.originY + y + ceilf((kSourceViewImageSide() - sourceSize.height) / 2);
    CGRect sourceLabelFrame = CGRectMake(left, sourceLabelOriginY, sourceSize.width, sourceSize.height);
    self.sourceLabelFrame = sourceLabelFrame;
    self.sourceLabelStr = sourceString;
    self.sourceLabelFontSize = kSourceViewFontSize();
    self.sourceLabelUserInteractionEnabled = YES;
    self.sourceLabelTextColorThemeKey = kSourceViewTextColor();
    self.sourceLabelHidden = NO;
    left += sourceSize.width + kFunctionViewPaddingSourceImageToSource();
    
    if ([[self.orderedData article] isSubscribe]) {
        NSString *subscriptString = [TTLayOutCellDataHelper getSubscriptStringWithOrderedData:self.orderedData];
        CGSize subscriptSize = [subscriptString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:12]}];
        subscriptSize = CGSizeMake(ceilf(subscriptSize.width), ceilf(subscriptSize.height));
        CGFloat subscriptLabelOriginY = self.originY + y + ceilf((kSourceViewImageSide() - subscriptSize.height) / 2);
        CGRect subscriptLabelFrame = CGRectMake(left, subscriptLabelOriginY, subscriptSize.width, subscriptSize.height);
        self.subscriptLabelFrame = subscriptLabelFrame;
        left += subscriptSize.width + kFunctionViewPaddingSourceImageToSource();
        self.subscriptLabelHidden = NO;
    }
    else{
        self.subscriptLabelHidden = YES;
    }
    
    NSString *entityString = [TTLayOutCellDataHelper getEntityStringWithOrderedData:self.orderedData];
    if (!isEmptyString(entityString)) {
        CGFloat moreImageViewOriginY = self.originY + y + ceilf((kSourceViewImageSide() - 12) / 2);
        CGRect moreImageViewFrame = CGRectMake(left, moreImageViewOriginY, 6, 12);
        self.moreImageViewFrame = moreImageViewFrame;
        self.moreImageViewHidden = NO;
        
        CGSize entitySize = [entityString sizeWithAttributes:@{NSFontAttributeName : [UIFont tt_fontOfSize:kSourceViewFontSize()]}];
        entitySize = CGSizeMake(ceilf(entitySize.width), ceilf(entitySize.height));
        left += 6 + kFunctionViewPaddingSourceImageToSource();
        CGFloat entityLabelOriginY = self.originY + y + ceilf((kSourceViewImageSide() - entitySize.height) / 2);
        CGRect entityLabelFrame = CGRectMake(left, entityLabelOriginY, entitySize.width, entitySize.height);
        self.entityLabelFrame = entityLabelFrame;
        self.entityLabelHidden = NO;
    }
    else{
        self.moreImageViewHidden = YES;
        self.entityLabelHidden = YES;
    }
    
    if ([[self.orderedData actionList] count] > 0) {
        CGFloat side = kMoreViewSide() + kMoreViewExpand() * 2;
        CGFloat moreButtonOriginY = self.originY + y + ceilf((kSourceViewImageSide() - side) / 2);
        CGRect moreButtonFrame = CGRectMake(self.cellWidth - kPaddingRight() + kMoreViewExpand() - side, moreButtonOriginY, side, side);
        self.moreButtonFrame = moreButtonFrame;
        self.moreButtonHidden = NO;
    }
    else{
        self.moreButtonHidden = YES;
    }
    
    y += kSourceViewImageSide() + kPaddingFunctionBottom();
    self.originY += y;
}

- (void)calculateOtherFramesWithContainWidth:(CGFloat)containWidth
{
    //implement in subclass
}

- (void)calculateInfoFrameWithY:(CGFloat)originY withContainWidth:(CGFloat)containWidth
{
    //implement in subclass
}
@end
