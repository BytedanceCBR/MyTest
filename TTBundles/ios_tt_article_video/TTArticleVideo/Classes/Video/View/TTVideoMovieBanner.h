//
//  TTVideoMovieBanner.h
//  Article
//
//  Created by 刘廷勇 on 16/4/20.
//
//

#import "SSViewBase.h"
#import "TTVideoBannerModel.h"
#import "TTVVideoDetailMovieBannerProtocol.h"
@class TTVideoMovieBanner;

@protocol TTVideoMovieBannerDelegate <NSObject>

- (void)didLoadImage:(TTVideoMovieBanner *)banner;

@end

@interface TTVideoMovieBanner : SSViewBase <TTVVideoDetailMovieBannerProtocol>

@property (nonatomic, weak) id<TTVideoMovieBannerDelegate> delegate;
@property (nonatomic, strong) TTVideoBannerModel *viewModel;
@property (nonatomic, copy) NSString *groupID;
- (instancetype)initWithWidth:(CGFloat)width;

@end
