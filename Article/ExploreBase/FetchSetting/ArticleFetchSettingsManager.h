//
//  ArticleFetchSettingsManager.h
//  Article
//
//  Created by Zhang Leonardo on 13-5-23.
//
//

#import "SSFetchSettingsManager.h"

// pgc 作品管理rn参数，无即表示不kaiq
#define kPGCWorkLibraryRNParams @"kPGCWorkLibraryRNParams"

@interface ArticleFetchSettingsManager : SSFetchSettingsManager
+ (NSString*)mineTabSellIntroduce;
/// 是否显示商城
+ (BOOL)isShowMallCellEntry;
@end
