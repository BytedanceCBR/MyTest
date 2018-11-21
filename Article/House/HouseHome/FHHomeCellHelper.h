//
//  FHHomeCellHelper.h
//  Article
//
//  Created by 谢飞 on 2018/11/21.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeCellHelper : NSObject

+(instancetype)sharedInstance;

/**
 * 根据配置数据计算头部高度
 */
+ (CGFloat)heightForFHHomeHeaderCellViewType;

@end

NS_ASSUME_NONNULL_END
