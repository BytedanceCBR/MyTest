//
//  FHHouseRealtorAvatarView.h
//  FHHouseBase
//
//  Created by bytedance on 2020/12/17.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class FHDetailContactModel;

@interface FHHouseRealtorAvatarView : UIView

@property (nonatomic, strong) UIImageView *avatarImageView;

@property (nonatomic, strong) UIImageView *identifyImageView;

- (void)updateAvatarImageURL:(nullable NSString *)url;

- (void)updateIdentifyImageURL:(nullable NSString *)url;

/// 经纪人Model
/// @param contactModel 如果api下发的是经纪人model接口，可以直接调用更新model的接口
- (void)updateAvatarWithModel:(FHDetailContactModel *)contactModel;


@end

NS_ASSUME_NONNULL_END
