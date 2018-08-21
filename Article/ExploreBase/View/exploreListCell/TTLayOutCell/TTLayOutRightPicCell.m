//
//  TTLayOutRightPicCell.m
//  Article
//
//  Created by 王双华 on 16/10/8.
//
//

#import "TTLayOutRightPicCell.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTArticleCellHelper.h"
#import "TTArticleCellConst.h"
#import "TTDeviceHelper.h"
#import "ExploreCellHelper.h"
#import "ExploreArticleCellViewConsts.h"
#import "TTLayOutPlainRightPicCellModel.h"
#import "TTLayOutUnifyADRightPicCellModel.h"
#import "TTLayOutUFRightPicCellModel.h"
#import "Article+TTADComputedProperties.h"
#import "ExploreOrderedData+TTAd.h"

@implementation TTLayOutRightPicCell

+ (Class)cellViewClass
{
    return [TTLayOutRightPicCellView class];
}

@end

@implementation TTLayOutRightPicCellView

- (void)refreshUI
{
    [super refreshUI];
    
    if (![self.orderedData preCellHasBottomPadding] && [self.orderedData hasTopPadding]) {
        CGRect bounds = self.bounds;
        bounds.origin.y = - kUFSeprateViewHeight();
        self.bounds = bounds;
        self.topRect.bottom = 0;
        self.topRect.width = self.width;
        self.topRect.hidden = NO;
    } else {
        CGRect bounds = self.bounds;
        bounds.origin.y = 0;
        self.bounds = bounds;
        self.topRect.hidden = YES;
    }
    
    if (![self.orderedData nextCellHasTopPadding] && [self.orderedData hasTopPadding]) {
        self.bottomRect.bottom = self.height + self.bounds.origin.y;
        self.bottomRect.width = self.width;
        self.bottomRect.hidden = NO;
    }
    else{
        self.bottomRect.hidden = YES;
    }
}

+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)listType
{
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if ([orderedData article]) {
        if (!orderedData.cellLayOut || orderedData.cellLayOut.needUpdateAllFrame){
            TTAdFeedCellDisplayType displayType = [orderedData.adModel displayType];
            if (displayType == TTAdFeedCellDisplayTypeRight && [orderedData.adModel showActionButton]) {
                orderedData.cellLayOut = [[TTLayOutUnifyADRightPicCellModel alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypeUnifyADCellRightPic;
            }
            else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle6){
                orderedData.cellLayOut = [[TTLayOutPlainRightPicCellModelS1 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellRightPicS1;
            }
            else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle7){
                orderedData.cellLayOut = [[TTLayOutPlainRightPicCellModelS2 alloc] init];
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellRightPicS2;
            }
//            else if ([orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle5
//                     || [orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle8
//                     || [orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle9
//                     || [orderedData.cellLayoutStyle integerValue] == TTLayOutCellLayOutStyle11){
//                orderedData.cellLayOut = [[TTLayOutUFRightPicCellModelS2 alloc] init];
//                orderedData.layoutUIType = TTLayOutCellUITypeUFCellLargePicS2;
//            }
            else{
                if (orderedData.isAd) {
                    orderedData.cellLayOut = [[TTLayOutPlainRightPicCellModelS0AD alloc] init];
                } else {
                    orderedData.cellLayOut = [[TTLayOutPlainRightPicCellModelS0 alloc] init];
                }
                orderedData.layoutUIType = TTLayOutCellUITypePlainCellRightPicS0;
            }
        }
    }
    TTLayOutCellBaseModel *cellLayOut = orderedData.cellLayOut;
    if ([cellLayOut needUpdateHeightCacheForWidth:width]) {
        [cellLayOut updateFrameForData:orderedData cellWidth:width listType:listType];
    }
    
    CGFloat height = cellLayOut.cellCacheHeight;
    if (height > 0) {
        if ([orderedData hasTopPadding]) {
            if ([orderedData nextCellHasTopPadding]){
                height -= kUFSeprateViewHeight();
            }
            if ([orderedData preCellHasBottomPadding]) {
                height -= kUFSeprateViewHeight();
            }
            if (height > 0) {
                return height;
            }
        }
        else{
            return height;
        }
    }
    return 0;

}

- (ExploreCellStyle)cellStyle {
    if ([self.orderedData.article.hasVideo boolValue]) {
        return ExploreCellStyleVideo;
    }
    else if (self.orderedData.article.isImageSubject) {
        return ExploreCellStylePhoto;
    }
    else {
        return ExploreCellStyleArticle;
    }
}

- (ExploreCellSubStyle)cellSubStyle {
    if ([self.orderedData isUnifyADCell]){
        return ExploreCellSubStyleUnknown;
    }
    if ([self.orderedData.article.hasVideo boolValue]) {
        return ExploreCellSubStyleVideoRightPic;
    }
    else if (self.orderedData.article.isImageSubject) {
        return ExploreCellSubStyleGalleryRightPic;
    }
    else {
        return ExploreCellSubStyleRighPic;
    }
}

- (CGRect)movieViewFrameRect {
    return [self convertRect:self.picView.bounds fromView:self.picView];
}

//- (UIView *)animationFromView
//{
//    return self.picView;
//}
//
//- (UIImage *)animationFromImage
//{
//    return [self.picView animationFromView].imageView.image;
//}
@end
