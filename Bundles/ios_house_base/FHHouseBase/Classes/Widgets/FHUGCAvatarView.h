//
//  FHUGCAvatarView.h
//  Pods
//
//  Created by bytedance on 2020/8/11.
//

#import <UIKit/UIKit.h>
#import "FHUGCCommonAvatar.h"

NS_ASSUME_NONNULL_BEGIN

@class FHDetailContactModel;
@class FHFeedUGCCellModel;
@class TSVUserModel;

@interface FHUGCAvatarView : UIView

@property (nonatomic, strong) FHUGCCommonAvatar *avatarImageView;
@property (nonatomic, strong) UIImageView *identifyImageView;
@property (nonatomic, copy) NSString *placeHoldName;
@property (nonatomic, copy) NSString *userId;



- (void)updateAvatarImageURL:(nullable NSString *)url;

- (void)updateIdentifyImageURL:(nullable NSString *)url;

/// 经纪人Model
/// @param contactModel 如果api下发的是经纪人model接口，可以直接调用更新model的接口
- (void)updateAvatarWithModel:(FHDetailContactModel *)contactModel;
- (void)updateAvatarWithUGCCellModel:(FHFeedUGCCellModel *)cellModel;
-(void)updateAvatarWithTSVUserModel:(TSVUserModel *)userModel;

@end

NS_ASSUME_NONNULL_END