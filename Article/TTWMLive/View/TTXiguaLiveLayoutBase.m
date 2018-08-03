//
//  TTXiguaLiveLayoutBase.m
//  Article
//
//  Created by lipeilun on 2017/12/1.
//

#import "TTXiguaLiveLayoutBase.h"
#import "TTArticleCellConst.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTCSSUIKitHelper.h"
#import "NSString+TTCSSUIKit.h"
#import "TTXiguaLiveModel.h"
#import <TTBusinessManager.h>
#import "TTUGCEmojiParser.h"
#import "TTThreadCellHelper.h"
#import "UGCCellHelper.h"
#import <TTVerifyIconHelper.h>
#import "ExploreCellHelper.h"

@implementation TTXiguaLiveLayoutBase

- (void)refreshComponentsLayoutWithData:(ExploreOrderedData *)orderData width:(CGFloat)width {
    TTXiguaLiveModel *xiguaModel = orderData.xiguaLiveModel;
    if (!xiguaModel) {
        return;
    }
    
    self.cellWidth = width;
    CGFloat cellHeight = kPaddingUFTop();

    CGFloat containerWidth = self.cellWidth - kPaddingLeft() - kPaddingRight();
    
    self.needTopPadding = !orderData.preCellHasBottomPadding && orderData.hasTopPadding;
    self.needBottomPadding = !orderData.isInCard && !orderData.nextCellHasTopPadding;
    if (self.needTopPadding) {
        cellHeight += kUFSeprateViewHeight();
        self.topSeparatorFrame = CGRectMake(0, 0, self.cellWidth, kUFSeprateViewHeight());
    } else {
        self.topSeparatorFrame = CGRectZero;
    }
    
    self.avatarViewFrame = CGRectMake(kPaddingLeft(), cellHeight, TTFLOAT(@"#ThreadU12Cell", @"avatarWidth"), TTFLOAT(@"#ThreadU12Cell", @"avatarWidth"));
    self.avatarUrl = [xiguaModel liveUserInfoModel].avatarUrl;
    self.userAuthInfo = [xiguaModel liveUserInfoModel].userAuthInfo;
    self.showVerifyIcon = [TTVerifyIconHelper isVerifiedOfVerifyInfo:self.userAuthInfo];
    
    self.dislikeButtonSize = TTSIZE(@"#ThreadU12Cell", @"dislikeSize");
    self.dislikeButtonCenterY = CGRectGetMidY(self.nameLabelFrame);
    self.dislikeButtonLeft = ceil(self.cellWidth - self.dislikeButtonSize.width + 6.5);
    
    self.nameLabelThemePath = @"#ThreadU11NameLabel";
    CGSize nameSize = [[xiguaModel liveUserInfoModel].name tt_sizeWithTheme:self.nameLabelThemePath constrainedWidth:self.dislikeButtonLeft - 6.5 - CGRectGetMaxX(self.avatarViewFrame) - kUFPaddingSourceImageToSource()];
    nameSize = CGSizeMake(ceil(nameSize.width), ceil(nameSize.height));
    self.nameLabelFrame = CGRectMake(CGRectGetMaxX(self.avatarViewFrame) + kUFPaddingSourceImageToSource(), cellHeight, nameSize.width, nameSize.height);
    
    self.descLabelThemePath = @"#ThreadU11vContentLabel";
    self.descLabelStr = [self totalDescStrWithLiveModel:xiguaModel];
    CGSize descContentSize = [self.descLabelStr tt_sizeWithTheme:self.descLabelThemePath constrainedWidth:FLT_MAX];
    descContentSize = CGSizeMake(ceil(descContentSize.width), ceil(descContentSize.height));
    self.descLabelFrame = CGRectMake(self.nameLabelFrame.origin.x, CGRectGetMaxY(self.nameLabelFrame) + 3, descContentSize.width, descContentSize.height);
    
    cellHeight += kUFS2SourceViewImageSide();
    NSString *mainContent = xiguaModel.title;
    if (!isEmptyString(mainContent)) {
        NSAttributedString *attrStr = [TTUGCEmojiParser parseInCoreTextContext:mainContent fontSize:kUFThreadContentFontSize()];
        if (attrStr.length > 0) {
            NSMutableAttributedString *mutableAttributedString = [attrStr mutableCopy];
            NSDictionary *attrDic = [UGCCellHelper threadContentLabelAttributesWithReadStatus:orderData.originalData.hasRead];
            [mutableAttributedString addAttributes:attrDic range:NSMakeRange(0, attrStr.length)];
            NSUInteger numberOfLines = 3;
            CGSize size = [TTThreadCellHelper sizeThatFitsAttributedString:mutableAttributedString
                                                           withConstraints:CGSizeMake(containerWidth + 2, FLT_MAX)
                                                          maxNumberOfLines:3
                                                    limitedToNumberOfLines:&numberOfLines];
            
            self.contentFrame = CGRectMake(kPaddingLeft() - 1, cellHeight + kUFS2PaddingSourceImageToContent(), containerWidth + 2, size.height);
            self.contentLines = numberOfLines;
            self.contentFontSize = kUFThreadContentFontSize();
            self.contentAttributedStr = [mutableAttributedString copy];
            if (size.height == 0) { //没正文，图片距离头像有点近（因为图文距离和文字头像距离不一样）
                cellHeight += (kUFS2PaddingSourceImageToContent() - TTFLOAT(@"#ThreadU12Cell", @"imgTopPadding")) + 5;
            } else {
                cellHeight += self.contentFrame.size.height + kUFS2PaddingSourceImageToContent();
            }
        }
    }
    
    FRImageInfoModel *imageModel = [xiguaModel largeImageModel];
    if (imageModel) {
        CGFloat imageHeight = ceil([ExploreCellHelper heightForImageWidth:imageModel.width height:imageModel.height constraintWidth:containerWidth]);
        self.largePicFrame = CGRectMake(kPaddingLeft(), cellHeight + kPaddingPicTop(), containerWidth, imageHeight);
        cellHeight += imageHeight + kPaddingPicTop();
    }

    cellHeight += 12;
    if (self.needBottomPadding) {
        self.bottomSeparatorFrame = CGRectMake(0, cellHeight, self.cellWidth, kUFSeprateViewHeight());
        cellHeight += kUFSeprateViewHeight();
    } else {
        self.bottomSeparatorFrame = CGRectZero;
    }
    self.cellHeight = cellHeight;
}

- (NSString *)totalDescStrWithLiveModel:(TTXiguaLiveModel *)liveModel {
    NSMutableString * result = [[NSMutableString alloc] init];
    
    //时间
    NSString * displayTime = [TTBusinessManager customtimeAndCustomdateStringSince1970:[liveModel liveLiveInfoModel].createTime.doubleValue];
    if (!isEmptyString(displayTime)) {
        [result appendString:displayTime];
    }
    
    //推荐理由
    if (!isEmptyString([liveModel liveUserInfoModel].authorInfo)) {
        //显示认证信息
        if (!isEmptyString(result)){
            [result appendString:@" · "];
        }
        [result appendString:[liveModel liveUserInfoModel].authorInfo];
    }
    
    return result.copy;
}

@end
