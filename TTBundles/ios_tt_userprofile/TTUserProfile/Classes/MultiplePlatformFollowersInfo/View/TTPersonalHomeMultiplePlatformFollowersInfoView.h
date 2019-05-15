//
//  TTPersonalHomeMultiplePlatformFollowersInfoView.h
//  Article
//
//  Created by 邱鑫玥 on 2018/1/9.
//

#import <UIKit/UIKit.h>

@class TTPersonalHomeMultiplePlatformFollowersInfoViewModel;

@interface TTPersonalHomeMultiplePlatformFollowersInfoView : UIView

@property (nonatomic, strong) TTPersonalHomeMultiplePlatformFollowersInfoViewModel *viewModel;

+ (CGFloat)heightForViewModel:(TTPersonalHomeMultiplePlatformFollowersInfoViewModel *)viewModel;

@end
