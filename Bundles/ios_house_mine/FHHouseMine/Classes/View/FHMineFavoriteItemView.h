//
//  FHMineFavoriteItemView.h
//  AFgzipRequestSerializer
//
//  Created by 谢思铭 on 2019/2/13.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHMineFavoriteItemView : UIView

- (instancetype)initWithName:(NSString *)name imageName:(NSString *)imageName;

@property(nonatomic, copy) void(^focusClickBlock)(void);

@end

NS_ASSUME_NONNULL_END
