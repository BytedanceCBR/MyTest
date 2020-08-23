//
//  FHRealtorAvatarView.h
//  Pods
//
//  Created by bytedance on 2020/8/11.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHDetailContactModel;

@interface FHRealtorAvatarView : UIView

@property (nonatomic, weak) UIImageView *avatarImageView;
@property (nonatomic, weak) UIImageView *identifyImageView;

- (void)updateAvatarImageURL:(NSString *)url;

- (void)updateIdentifyImageURL:(NSString *)url;

/// 经纪人Model
/// @param contactModel 如果api下发的是经纪人model接口，可以直接调用更新model的接口
- (void)updateAvatarWithModel:(FHDetailContactModel *)contactModel;

@end

NS_ASSUME_NONNULL_END
