//
//  FHMineFavoriteItemView.h
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/13.
//

#import <UIKit/UIKit.h>
#import "FHMineDefine.h"
NS_ASSUME_NONNULL_BEGIN

@interface FHMineFavoriteItemView : UIView

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName  moduletype:(FHMineModuleType )moduleType;
@property (nonatomic, strong) UILabel *nameLabel;
@property(nonatomic, copy) void(^itemClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
