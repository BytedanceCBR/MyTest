//
//  TTVVideoDetailMovieBanner.h
//  Article
//
//  Created by pei yun on 2017/5/26.
//
//

#import <TTThemed/SSThemed.h>
#import "TTVVideoDetailNatantVideoBannerDataProtocol.h"
#import "TTVVideoDetailMovieBannerProtocol.h"

@class TTVVideoDetailMovieBanner;
@protocol TTVVideoDetailMovieBannerDelegate <NSObject>

- (void)didLoadImage:(TTVVideoDetailMovieBanner *)banner;

@end

@interface TTVVideoDetailMovieBanner : SSViewBase <TTVVideoDetailMovieBannerProtocol>

@property (nonatomic, weak) id<TTVVideoDetailMovieBannerDelegate> delegate;
@property (nonatomic, strong) id<TTVVideoDetailNatantVideoBannerDataProtocol> viewModel;
@property (nonatomic, copy) NSString *groupID;

@end
