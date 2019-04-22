//
//  TTUnifyADVideoCategoryLargePicCell.m
//  Article
//
//  Created by 王双华 on 16/9/7.
//
//

#import "TTUnifyADVideoCategoryLargePicCell.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "NewsUserSettingManager.h"
#import "TTArticleCellConst.h"
#import "TTArticleCellHelper.h"
#import "TTDeviceHelper.h"
#import "TTLabelTextHelper.h"
#import "TTLayOutCellDataHelper.h"
#import "ExploreOrderedData+TTAd.h"

#define kTopMaskH 80

#define kBottomViewH [TTDeviceUIUtils tt_newPadding:6]
#define knew_BottomViewH [TTDeviceUIUtils tt_newPadding:3]
#define kVideoTitleY ([TTDeviceHelper isScreenWidthLarge320]?15.0:8.0)

@interface TTUnifyADVideoCategoryLargePicCell ()

@end

@implementation TTUnifyADVideoCategoryLargePicCell
/**
 更新数据界面
 
 - parameter data: data数据
 */
- (void)refreshWithData:(id)data {
    NSParameterAssert(data != nil);
    
    if (![data isKindOfClass:[ExploreOrderedData class]]) {
        return;
    }
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
    if (![orderedData.article isKindOfClass:[Article class]]) {
        return;
    }
    self.orderedData = orderedData;
    self.picView.style = TTArticlePicViewStyleLarge;
    [self.picView updateADPics:orderedData];
    [self updateTopMaskView];
    [self updateVideoTitleLabel];
    [self updateActionBar];
    [self.picView insertSubview:self.videoTitleLabel aboveSubview:self.topMaskView];
}

/**
 更新UI界面
 */
- (void)refreshUI {
    
    self.picView.picView1.layer.borderWidth = 0.f;
    
    CGFloat containWidth = self.cellView.width;
    // 根据图片实际宽高设置其在cell中的高度
    
    CGFloat y = 0;
    // 布局标题控件
    NSString *title =  [TTLayOutCellDataHelper getTitleStyle2WithOrderedData:self.orderedData];
    
    // 布局图片(视频)控件
    BOOL isPad = [TTDeviceHelper isPadDevice];
    float left = isPad ? kPaddingLeft() : 0;
    float picWidth = isPad ? (containWidth - 2 * kPaddingLeft()) : containWidth;
    self.topMaskView.frame = CGRectMake(0, 0, picWidth, kTopMaskH);
    
    if (!isEmptyString(title)) {
        CGFloat titleHeight = [TTLabelTextHelper heightOfText:title fontSize:kVideoCellTitleFontSize() forWidth:picWidth - kPaddingLeft() - kPaddingRight() constraintToMaxNumberOfLines:2];
        self.videoTitleLabel.frame = CGRectMake(kPaddingLeft(), kVideoTitleY, picWidth - kPaddingLeft() - kPaddingRight(), titleHeight);
    }
    
    id<TTAdFeedModel> adModel = self.orderedData.adModel;
    CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:self.orderedData adModel:adModel.imageModel picStyle:TTArticlePicViewStyleLarge width:picWidth];
    self.picView.frame = CGRectMake(left, 0, picSize.width, picSize.height);
    y += picSize.height;
    
    // 布局Action控件
    self.actionBar.frame = CGRectMake(0, y, containWidth, [self.class actionBarHeigth]);
    [self updateActionBar];
    y += [self.class actionBarHeigth];
    
    self.bottomLineView.frame =  CGRectMake(left, y, picWidth, [TTDeviceHelper ssOnePixel]);
    y += [TTDeviceHelper ssOnePixel];
    
    self.bottomSepView.frame = CGRectMake(left, y, picWidth, kCellSeprateViewHeight());
}

/**
 计算数据对应Cell高度
 
 - parameter data:      data数据
 - parameter cellWidth: Cell宽度
 - parameter listType:  列表类型
 
 - returns: 数据对应Cell高度
 */
+ (CGFloat)heightForData:(id)data cellWidth:(CGFloat)cellWidth listType:(ExploreOrderedDataListType)cellType {
    ExploreOrderedData *orderedData = (ExploreOrderedData *)data;
//    Article *article = orderedData.article;
    if (orderedData) {
        id<TTAdFeedModel> adModel = orderedData.adModel;
        
        CGFloat height = 0;
        
        // 计算图片控件
        BOOL isPad = [TTDeviceHelper isPadDevice];
        float picWidth = isPad ? (cellWidth - 2 * kPaddingLeft()) : cellWidth;
        CGSize picSize = [TTArticleCellHelper getPicSizeByOrderedData:orderedData adModel:adModel.imageModel picStyle:TTArticlePicViewStyleLarge width:picWidth];
        height += picSize.height;
        
        // actionbar控件以及分割线
        if ([TTDeviceHelper isPadDevice]) {
            height += [self.class actionBarHeigth] + [TTDeviceHelper ssOnePixel];
        }
        else {
            if (ttvs_isVideoFeedCellHeightAjust() == 1) {
                height += [self.class actionBarHeigth] + knew_BottomViewH + [TTDeviceHelper ssOnePixel];
            }else if(ttvs_isVideoFeedCellHeightAjust() >1){
                height += [self.class actionBarHeigth];
            }else{
                height += [self.class actionBarHeigth] + kBottomViewH + [TTDeviceHelper ssOnePixel];
            }
        }
        
        if (![TTDeviceHelper isPadDevice] && [orderedData nextCellHasTopPadding]) {
            height -= (kCellSeprateViewHeight() + [TTDeviceHelper ssOnePixel]);
        }
        return height;
    }
    return 0;
}

- (void)didSelectAtIndexPath:(NSIndexPath *)indexPath viewModel:(nonnull TTFeedContainerViewModel *)viewModel {
    [super didSelectAtIndexPath:indexPath viewModel:viewModel];
    if (self.orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        if ([self.actionBar.adActionButton isKindOfClass:[ExploreActionButton class]]) {
            [self.actionBar.adActionButton actionButtonClicked:nil showAlert:YES];
        }
    }
}

- (void)didSelectWithContext:(TTFeedCellSelectContext *)context {
    [self.cellView didSelectWithContext:context];
    if (self.orderedData.cellType == ExploreOrderedDataCellTypeAppDownload) {
        if ([self.actionBar.adActionButton isKindOfClass:[ExploreActionButton class]]) {
            [self.actionBar.adActionButton actionButtonClicked:nil showAlert:YES];
        }
    }
}

static CGFloat sActionBarHeight = 0;
+ (CGFloat)actionBarHeigth {
//    if (sActionBarHeight) {
//        return sActionBarHeight;
//    }
    if (ttvs_isVideoFeedCellHeightAjust() >0){
        sActionBarHeight = [TTDeviceUIUtils tt_newPadding:48];
    }else{
        sActionBarHeight = [TTDeviceUIUtils tt_newPadding:52];
    }
    return sActionBarHeight;
}

@end

