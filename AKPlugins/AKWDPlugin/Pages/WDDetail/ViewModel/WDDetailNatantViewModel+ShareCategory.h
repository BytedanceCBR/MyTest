//
//  WDDetailNatantViewModel+ShareCategory.h
//  Article
//
//  Created by 延晋 张 on 2017/1/24.
//
//

#import "WDDetailNatantViewModel.h"
#import "TTFavouriteContentItem.h"

@protocol TTActivityContentItemProtocol;

@interface WDDetailNatantViewModel (ShareCategory)

- (NSString *)shareTitle;
- (NSString *)shareDesc;
- (NSString *)shareUrl;
- (NSString *)shareImgUrl;
- (UIImage *)shareImage;
- (NSArray<id<TTActivityContentItemProtocol>> *)wd_shareItems;

@end
