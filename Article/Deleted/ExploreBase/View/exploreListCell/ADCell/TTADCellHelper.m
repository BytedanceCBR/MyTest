//
//  TTADCellHelper.m
//  Article
//
//  Created by 杨心雨 on 16/8/21.
//
//

#import "TTADCellHelper.h"

#import "Article+TTADComputedProperties.h"
#import "Article.h"
#import "ExploreOrderedActionCell.h"
#import "ExploreOrderedData+TTAd.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "ExploreOrderedData.h"
#import "SSCommonLogic.h"
#import "TTLayOutGroupPicCell.h"
#import "TTLayOutLargePicCell.h"
#import "TTLayOutRightPicCell.h"
#import "TTLayoutLoopPicCell.h"
#import "TTLayoutPanorama3DViewCell.h"
#import "TTLayoutPanoramaViewCell.h"
#import "TTUnifyADPicCategoryLargePicCell.h"
#import "TTUnifyADVideoCategoryLargePicCell.h"
#import "TTLayOutNewLargePicCell.h"

@interface TTAdExploreCellHelper : NSObject <TTCellDataHelper>
@end

@implementation TTAdExploreCellHelper
/**
 check if the ordered data is valid
 
 - parameter orderData: ordered data
 
 - returns: return unwrap order data if valid else nil
 */
+ (ExploreOrderedData *)verifyADDataWithOrderData:(ExploreOrderedData *)orderedData {
    if (orderedData != nil) {
        //应用下载或者电话拨打广告
        if (!isEmptyString([orderedData article].adPromoter)) {
            return orderedData;
        }
        
        if (orderedData.videoChannelADType == kLargePicADCellInVideoCategoryDisplayType) {
            return orderedData;
        }
        
        if (orderedData.videoChannelADType == kLargePicADCellInVideoCategoryNewDisplayType) {
            return orderedData;
        }
        
        if (orderedData.largePicCeativeType == kLargePicADCellInPicCategoryDisplayType) {
            return orderedData;
        }
    }
    return nil;
}

+ (Class)cellClassFromData:(ExploreOrderedData *)data {
    ExploreOrderedData *orderedData = [self verifyADDataWithOrderData:data];
    //先处理视频频道大图广告样式
    if (orderedData.videoChannelADType == kLargePicADCellInVideoCategoryDisplayType) {
        return [TTUnifyADVideoCategoryLargePicCell class];
    }
    if (orderedData.largePicCeativeType == kLargePicADCellInPicCategoryDisplayType) {
        return [TTUnifyADPicCategoryLargePicCell class];
    }
    //然后处理是否有大图升级样式1
    
    if (orderedData) {
        TTAdFeedCellDisplayType displayType = (TTAdFeedCellDisplayType)[orderedData.adModel displayType];
        if (displayType != 0) {
            switch (displayType) {
                case TTAdFeedCellDisplayTypeLarge:
                    if ([SSCommonLogic feedNewPlayerEnabled]) {
                        return [TTLayOutNewLargePicCell class];
                    } else {
                        return [TTLayOutLargePicCell class];
                    }
                    break;
                case TTAdFeedCellDisplayTypeGroup:
                    return [TTLayOutGroupPicCell class];
                    break;
                case TTAdFeedCellDisplayTypeRight:
                    return [TTLayOutRightPicCell class];
                    break;
                default:
                    return [ExploreOrderedActionSmallCell class];
                    break;
            }
        }
    }
    return nil;
}

@end

@interface TTAdRawCellHelper : NSObject <TTCellDataHelper>
@end

@implementation TTAdRawCellHelper
/**
 check if the ordered data is valid
 
 - parameter orderData: ordered data
 
 - returns: return unwrap order data if valid else nil
 */
+ (ExploreOrderedData *)verifyADDataWithOrderData:(ExploreOrderedData *)orderedData {
    if (orderedData.videoStyle > 2) { // 视频频道不处理
        return nil;
    }
    
    if (orderedData.cellType != ExploreOrderedDataCellTypeAppDownload &&
        orderedData.cellType != ExploreOrderedDataCellTypeArticle) {
        return nil;
    }
    
    TTAdFeedCellDisplayType displayType = (TTAdFeedCellDisplayType)[orderedData.adModel displayType];
    if (displayType >= TTAdFeedCellDisplayTypeSmall  &&
        displayType <= TTAdFeedCellDisplayType3DPanorama) {
        return orderedData;
    }
    return nil;
}

+ (Class)cellClassFromData:(ExploreOrderedData *)data {
    ExploreOrderedData *orderedData = [self verifyADDataWithOrderData:data];
    if (orderedData == nil) {
        return nil;
    }
    
    TTAdFeedCellDisplayType displayType = (TTAdFeedCellDisplayType)[orderedData.adModel displayType];
    switch (displayType) {
        case TTAdFeedCellDisplayTypeLarge:
            if ([SSCommonLogic feedNewPlayerEnabled]) {
                return [TTLayOutNewLargePicCell class];
            } else {
                return [TTLayOutLargePicCell class];
            }
            break;
        case TTAdFeedCellDisplayTypeGroup:
            return [TTLayOutGroupPicCell class];
            break;
        case TTAdFeedCellDisplayTypeRight:
            return [TTLayOutRightPicCell class];
            break;
        case TTAdFeedCellDisplayTypeLarge_VideoChannel:
            return [TTUnifyADVideoCategoryLargePicCell class];
            break;
        case TTAdFeedCellDisplayTypeLarge_ImageChannel:
            return [TTUnifyADPicCategoryLargePicCell class];
            break;
        case TTAdFeedCellDisplayTypeSlider:
            return [TTLayoutLoopPicCell class];
            break;
        case TTAdFeedCellDisplayTypeFullScreen:
            return [TTLayoutPanoramaViewCell class];
            break;
        case TTAdFeedCellDisplayType3DPanorama:
            return [TTLayoutPanorama3DViewCell class];
            break;
        case TTAdFeedCellDisplayTypeSmall: // who is stupied, who know it.
            if (orderedData.article.listLargeImageModel != nil) {
                if ([SSCommonLogic feedNewPlayerEnabled]) {
                    return [TTLayOutNewLargePicCell class];
                } else {
                    return [TTLayOutLargePicCell class];
                }
            } else if (orderedData.article.listGroupImgModels.count >= 3) {
                return [TTLayOutGroupPicCell class];
            } else if (orderedData.article.listMiddleImageModel != nil) {
                return [TTLayOutRightPicCell class];
            }
            return [ExploreOrderedActionSmallCell class];
            break;
        default:
            break;
    }
    
    //然后处理是否有大图升级样式1
    return nil;
}
@end


@implementation TTADCellHelper

+ (Class)cellClassFromData:(ExploreOrderedData *)orderedData {
    if (![orderedData isKindOfClass:[ExploreOrderedData class]]) {
        return nil;
    }
    
    if ([SSCommonLogic isRawAdDataEnable]) {
        return [TTAdRawCellHelper cellClassFromData:orderedData];
    }
    
    Class cellClass = nil;
    if (cellClass == nil) {
        cellClass = [TTAdExploreCellHelper cellClassFromData:orderedData];
    }
    
    if (orderedData.raw_ad != nil) {
        cellClass = [TTAdRawCellHelper cellClassFromData:orderedData];
    }
    
    return cellClass;
}

+ (void)registerCellViewAndCellDataHelper {
    [[TTCellBridge sharedInstance] registerCellDataClass:[ExploreOrderedData class] cellDataHelperClass:self];
}

@end
