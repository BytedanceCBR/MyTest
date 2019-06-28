//
//  FHUGCCellHelper.h
//  FHHouseUGC
//
//  Created by 谢思铭 on 2019/6/6.
//

#import <Foundation/Foundation.h>
#import "TTUGCAttributedLabel.h"
#import "TTRichSpanText.h"
#import "TTBaseMacro.h"
#import "TTUGCEmojiParser.h"
#import "FHFeedUGCContentModel.h"
#import "FHFeedUGCCellModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCellHelper : NSObject

+ (NSAttributedString *)truncationFont:(UIFont *)font contentColor:(UIColor *)contentColor color:(UIColor *)color linkUrl:(NSString *)linkUrl;

+ (void)setRichContent:(TTUGCAttributedLabel *)label model:(FHFeedUGCCellModel *)model numberOfLines:(NSInteger)numberOfLines;

@end

NS_ASSUME_NONNULL_END
