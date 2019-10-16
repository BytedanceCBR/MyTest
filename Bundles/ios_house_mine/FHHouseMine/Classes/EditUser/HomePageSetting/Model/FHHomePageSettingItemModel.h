//
//  FHHomePageSettingItemModel.h
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/10/16.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHHomePageSettingItemModel : NSObject

@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) NSInteger auth;
@property (nonatomic, assign) BOOL isSelected;

@end

NS_ASSUME_NONNULL_END
