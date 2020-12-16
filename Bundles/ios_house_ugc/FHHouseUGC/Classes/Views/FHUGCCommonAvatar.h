//
//  FHUGCCommonAvatar.h
//  FHHouseUGC
//
//  Created by liuyu on 2020/12/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface FHUGCCommonAvatar : UIView
@property (assign, nonatomic) BOOL showTag;
@property (strong , nonatomic) UIImageView *avatar;
@property (strong, nonatomic) id userId;
- (void)setAvatarUrl:(NSString *)avatarStr;

- (void)setPlaceholderImage:(NSString *)imageName;




@end

NS_ASSUME_NONNULL_END
