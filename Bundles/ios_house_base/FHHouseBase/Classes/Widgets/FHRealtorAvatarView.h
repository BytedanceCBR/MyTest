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



@end

NS_ASSUME_NONNULL_END
