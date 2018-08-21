//
//  TTArticleCellHelper.m
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "TTArticleCellHelper.h"
#import "TTThemeManager.h"
#import "TTArticleCellConst.h"
#import "ExploreCellBase.h"
#import "NewsLogicSetting.h"
#import "ExploreCellHelper.h"
#import "TTDeviceHelper.h"
#import "NSString-Extension.h"
#import "NewsUserSettingManager.h"
#import "TTUserSettings/TTUserSettingsManager+FontSettings.h"
#import "Article+TTADComputedProperties.h"

// MARK: - TTArticleCellHelper
@implementation TTArticleCellHelper
/** 单例 */
+ (instancetype)shareHelper {
    static TTArticleCellHelper *ttArticleCellHelper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        ttArticleCellHelper = [[TTArticleCellHelper alloc] init];
    });
    return ttArticleCellHelper;
}

// MARK: 控件尺寸
/**
 获取顶部功能区控件尺寸
 
 - parameter orderedData: OrderedData数据
 - parameter width:       应占宽度
 
 - returns: 顶部功能区尺寸
 */
+ (CGSize)getFunctionSize:(ExploreOrderedData *)orderedData width:(CGFloat)width {
    CGSize size = CGSizeZero;
    size.width = width;
    size.height = kSourceViewImageSide();
    if (!isEmptyString([orderedData recommendReason])) {
        size.height += kLikeViewFontSize() + kFunctionViewPaddingLikeToSource();
    }
    return size;
}

/**
 获取标题控件尺寸
 
 - parameter title:           标题文字
 - parameter width:           应占宽度
 - parameter fontSize:        字体大小(默认标题字体大小)
 - parameter lineHeight:      行高(默认标题行高)
 - parameter isBold:          是否加粗(默认不加粗)
 - parameter numberOfLines:   行数限制(默认标题行数限制)
 - parameter firstLineIndent: 首行缩进(默认0)
 
 - returns: (标题控件尺寸, 行数)
 */
//    class func getTitleSize(title: String, width: CGFloat, fontSize: CGFloat = kTitleViewFontSize(), lineHeight: CGFloat = kTitleViewLineHeight(), isBold: Bool = false, numberOfLines: Int = kTitleViewLineNumber(), firstLineIndent: CGFloat = 0) -> (size: CGSize, line: Int)
+ (CGSize)getTitleSize:(NSString *)title width:(CGFloat)width fontSize:(CGFloat)fontSize lineHeight:(CGFloat)lineHeight isBold:(BOOL)isBold numberOfLines:(NSInteger)numberOfLines firstLineIndent:(CGFloat)firstLineIndent {
    CGSize size = CGSizeZero;
    if (!isEmptyString(title)) {
        UIFont *font = isBold ? [UIFont tt_boldFontOfSize:fontSize] : [UIFont tt_fontOfSize:fontSize];
        CGFloat height = [title tt_sizeWithMaxWidth:width font:font lineHeight:lineHeight numberOfLines:numberOfLines firstLineIndent:firstLineIndent].height;
        size.width = width;
        size.height = height;
    }
    return size;
}

+ (CGSize)getTitleSize:(NSString *)title width:(CGFloat)width {
    return [self getTitleSize:title width:width fontSize:kTitleViewFontSize() lineHeight:kTitleViewLineHeight() isBold:NO numberOfLines:kTitleViewLineNumber() firstLineIndent:0];
}

+ (CGSize)getTitleSize:(NSString *)title width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    return [self getTitleSize:title width:width fontSize:kTitleViewFontSize() lineHeight:kTitleViewLineHeight() isBold:NO numberOfLines:numberOfLines firstLineIndent:0];
}

/**
 获取摘要控件尺寸
 
 - parameter article: Article数据
 - parameter width:   应占宽度
 
 - returns: 摘要控件尺寸
 */
+ (CGSize)getAbstractSize:(Article *)article width:(CGFloat)width  numberOfLines:(NSInteger)numberOfLines {
    CGSize size = CGSizeZero;
    if (!isEmptyString([article abstract])) {
        CGFloat height = [[article abstract] tt_sizeWithMaxWidth:width font:[UIFont tt_fontOfSize:kAbstractViewFontSize()] lineHeight:kAbstractViewLineHeight() numberOfLines:numberOfLines].height;
        size.width = width;
        size.height = height;
    }
    return size;
}

+ (CGSize)getAbstractSize:(Article *)article width:(CGFloat)width {
    return [self getAbstractSize:article width:width numberOfLines:kAbstractViewLineNumber()];
}

/**
 是否显示摘要控件
 
 - parameter article:  Article数据
 - parameter listType: 列表样式
 
 - returns: 是否显示摘要控件
 */
+ (BOOL)shouldDisplayAbstractView:(Article *)article listType: (ExploreOrderedDataListType)listType mustShow:(BOOL)mustShow {
    BOOL result = NO;
    
    if (isEmptyString([article abstract])) {
        return NO;
    }
    if (mustShow) {
        return YES;
    }
    
    if (listType == ExploreOrderedDataListTypeFavorite || listType == ExploreOrderedDataListTypeReadHistory || listType == ExploreOrderedDataListTypePushHistory) {
        if ([TTDeviceHelper isPadDevice]) {
            result = ([NewsLogicSetting userSetReadMode] == ReadModeAbstract);
        }
    } else if ([NewsLogicSetting userSetReadMode] == ReadModeAbstract) {
        result = YES;
    }
    return result;
}

+ (BOOL)shouldDisplayAbstractView:(Article *)article listType: (ExploreOrderedDataListType)listType {
    return [self shouldDisplayAbstractView:article listType:listType mustShow:NO];
}

    
/**
 获取评论控件尺寸
 
 - parameter article: Article数据
 - parameter width:   应占宽度
 
 - returns: 评论控件尺寸
 */
+ (CGSize)getCommentSize:(Article *)article width:(CGFloat)width numberOfLines:(NSInteger)numberOfLines {
    CGSize size = CGSizeZero;
    if ([article displayComment]) {
        NSString* commentText = [article commentContent];
        CGFloat height = [commentText tt_sizeWithMaxWidth:width font:[UIFont tt_fontOfSize:kCommentViewFontSize()] lineHeight:kCommentViewLineHeight() numberOfLines:numberOfLines].height;
        size.width = width;
        size.height = height;
    }
    return size;
}

+ (CGSize)getCommentSize:(Article *)article width:(CGFloat)width {
    return [self getCommentSize:article width:width numberOfLines:kCommentViewLineNumber()];
}

/**
 是否显示评论控件
 
 - parameter article:  Article数据
 - parameter listType: 列表样式
 
 - returns: 是否显示评论控件
 */
+ (BOOL)shouldDisplayCommentView:(Article *)article listType:(ExploreOrderedDataListType)listType {
    BOOL result = NO;
    if (listType == ExploreOrderedDataListTypeFavorite || listType == ExploreOrderedDataListTypeReadHistory || listType == ExploreOrderedDataListTypePushHistory || [TTDeviceHelper isPadDevice]) {
        result = NO;
    } else if ([article displayComment]) {
        result = YES;
    }
    return result;
}
    
/**
 获取图片(视频)控件尺寸
 
 - parameter article:  Article数据
 - parameter picStyle: 图片(视频)控件样式
 - parameter width:    应占宽度
 
 - returns: 图片(视频)控件尺寸
 */
//    class func getPicSize(article: Article? = nil, adModel: imageModel, picStyle: TTArticlePicViewStyle, width: CGFloat) -> CGSize {

+ (CGSize)getPicSizeByOrderedData:(ExploreOrderedData *)orderedData picStyle:(TTArticlePicViewStyle)picStyle width:(CGFloat)width {
    return [self getPicSizeByOrderedData:orderedData adModel:nil picStyle:picStyle width:width];
}

+ (CGSize)getPicSizeByOrderedData:(ExploreOrderedData *)orderedData adModel:(TTImageInfosModel *)imageModel picStyle:(TTArticlePicViewStyle)picStyle width:(CGFloat)width {
    Article *article = orderedData.article;
    CGSize size = CGSizeZero;
    
    CGSize picSize = [TTArticleCellHelper resizablePicSize:width];
    size.width = width;
    switch (picStyle) {
        case TTArticlePicViewStyleNone:
            size.width = 0;
            size.height = 0;
            break;
        case TTArticlePicViewStyleRight:
            size.width = picSize.width;
            size.height = picSize.height;
            break;
        case TTArticlePicViewStyleLarge:
            if (imageModel) {
                size.height = ceil([ExploreCellHelper heightForImageWidth:[imageModel width] height:[imageModel height] constraintWidth:width]);
            } else if (article == nil || [[article gallaryFlag] isEqualToNumber:@1]) {
                size.height = ceil(width * 9 / 16);
            } else if ([orderedData listLargeImageDict]) {
                TTImageInfosModel *model = [[TTImageInfosModel alloc] initWithDictionary:[orderedData listLargeImageDict]];
                if (model) {
                    size.height = ceil([ExploreCellHelper heightForImageWidth:[model width] height:[model height] constraintWidth:width]);
                }
            }
            break;
        case TTArticlePicViewStyleTriple:
            size.height = picSize.height;
            break;
        case TTArticlePicViewStyleLeftLarge:
            size.height = picSize.height * 2 + kPicViewPaddingInner();
            break;
        case TTArticlePicViewStyleRightLarge:
            size.height = picSize.height * 2 + kPicViewPaddingInner();
            break;
        case TTArticlePicViewStyleLeftSmall:
            size.width = kUFLeftPicViewSide();
            size.height = kUFLeftPicViewSide();
            break;
    }
    return size;
}



+ (CGSize)getLoopPicSizeWithOrderData:(ExploreOrderedData *)orderData WithContainWidth:(CGFloat)containWidth WithPicPadding:(CGFloat)picPadding WithEdgePadding:(CGFloat)edgePadding{
    
    CGSize picSize = CGSizeZero;
    if (orderData && orderData.article) {
        
        Article *article = orderData.article;
        if (!SSIsEmptyArray(article.listGroupImgDicts)) {
            
            NSMutableArray *picModelsArray = [[NSMutableArray alloc] init];
            
            for (NSDictionary *picDic in article.listGroupImgDicts) {
                TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:picDic];
                if (model) {
                    [picModelsArray addObject:model];
                }
            }
            
            if (picModelsArray.count == 1) {
                
                NSDictionary *picDic = [article.listGroupImgDicts objectAtIndex:0];
                TTImageInfosModel * model = [[TTImageInfosModel alloc] initWithDictionary:picDic];
                
                if (model) {
                    picSize.width = containWidth - 2 * edgePadding;
                    picSize.height = ceil([ExploreCellHelper heightForLoopImageWidth:[model width] height:[model height] constraintWidth:(containWidth - 2 * edgePadding)]);
                }
                
            }
            
            else if (picModelsArray.count > 1){
                
                TTImageInfosModel * model = [picModelsArray objectAtIndex:0];
                
                CGFloat width = ceil((double)(containWidth - edgePadding - picPadding) * 27/35);
                CGFloat height = 0;
                if (width > 0) {
                    height = ceil([ExploreCellHelper heightForLoopImageWidth:[model width] height:[model height] constraintWidth:width]);
                    
                    picSize.width = width;
                    picSize.height = height;
                }
            }
        }
    }
    
    return picSize;
    
}

/**
 获取小图尺寸
 
 - parameter width: 三小图应占宽度
 
 - returns: 小图尺寸
 */
+ (CGSize)resizablePicSize:(CGFloat)width {
    CGFloat w = (width - kPicViewPaddingInner() * 2) / 3;
    CGFloat h = ceil(w * 0.6935);
    w = ceil(w);
    return CGSizeMake(w, h);
}
    
/**
 获取正方形小图尺寸
 
 - parameter width: 横排三图的总宽度
 
 - returns:正方形小图尺寸
 */
+ (CGSize)resizableSquareMultiPicsSize:(CGFloat)width {
    CGFloat w = (width - kSquareViewPaddingInner() * 2) / 3;
    w = ceil(w);
    return CGSizeMake(w, w);
}
    
/**
 获取信息栏控件尺寸
 
 - parameter width: 应占宽度
 
 - returns: 信息栏控件尺寸
 */
+ (CGSize)getInfoSize:(CGFloat)width {
    CGSize size = CGSizeZero;
    size.width = width;
    size.height = kInfoViewHeight();
    return size;
}

+ (CGSize)getADActionSize:(CGFloat)width {
    CGSize size = CGSizeZero;
    size.width = width;
    size.height = 44;
    return size;
}

/** 可变字号 */
+ (CGFloat)mutableFontSize:(CGFloat)size {
    return [self deviceChangeSize:[self settingSize:size]];
}

/** 固定字号 */
+ (CGFloat)fontSize:(CGFloat)size {
    return [self deviceChangeSize:size];
}

+ (CGFloat)settingSize:(CGFloat)size {
    TTUserSettingsFontSize selectedIndex = [TTUserSettingsManager settingFontSize];
    switch (selectedIndex) {
        case TTFontSizeSettingTypeMin: return size - 2;
        case TTFontSizeSettingTypeNormal: return size;
        case TTFontSizeSettingTypeBig: return size + 2;
        case TTFontSizeSettingTypeLarge: return size + 5;
    }
}

/** 根据设备对字号进行调整 */
+ (CGFloat)deviceChangeSize:(CGFloat)size {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return size + size > 15 ? 5 : 2;
        case TTDeviceMode736: return size + size > 15 ? 2 : 1;
        case TTDeviceMode667:
        case TTDeviceMode812: return size;
        case TTDeviceMode568: return size + size > 15 ? -2 : -1;
        case TTDeviceMode480: return size + size > 15 ? -2 : -1;
    }
}

/** 对行高进行调整 */
+ (CGFloat)lineHeight:(CGFloat)size {
    return ceil(size);
}

/** 根据设备对间距进行调整 */
+ (CGFloat)padding:(CGFloat)size {
    switch ([TTDeviceHelper getDeviceType]) {
        case TTDeviceModePad: return ceil(size * 1.3);
        case TTDeviceMode736: return ceil(size * 1.1);
        case TTDeviceMode667:
        case TTDeviceMode812: return ceil(size);
        case TTDeviceMode568: return ceil(size * 0.85);
        case TTDeviceMode480: return ceil(size * 0.85);
    }
}

@end


@implementation UIFont (TTFont)

+ (UIFont *)tt_boldFontOfSize:(CGFloat)size {
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
        if ([UIFont fontWithName:@"PingFangSC-Medium" size:size]) {
            return [UIFont fontWithName:@"PingFangSC-Medium" size:size];
        }
    }
    return [UIFont boldSystemFontOfSize:size];
}

+ (UIFont *)tt_fontOfSize:(CGFloat)size {
    if ([[UIDevice currentDevice].systemVersion doubleValue] >= 9.0) {
        if ([UIFont fontWithName:@"PingFangSC-Regular" size:size]) {
            return [UIFont fontWithName:@"PingFangSC-Regular" size:size];
        }
    }
    return [UIFont systemFontOfSize:size];
}

@end

@implementation UIColor (TTColor)

+ (UIColor *)colorForKey:(NSString *)colorKey {
    return [[TTThemeManager sharedInstance_tt] themedColorForKey:colorKey];
}

@end
