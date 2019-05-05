//
//  TSVActivityBannerCollectionViewCell.m
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import "TSVActivityBannerCollectionViewCell.h"
#import "TSVAnimatedImageView.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TSVActivityBannerCollectionViewCell()

@property (nonatomic, strong) TSVAnimatedImageView *coverImageView;

@end

@implementation TSVActivityBannerCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    if (self = [super initWithFrame:frame]) {
        self.coverImageView = ({
            TSVAnimatedImageView *imageView = [[TSVAnimatedImageView alloc] init];
            imageView.backgroundColorThemeKey = kColorBackground3;
            imageView.imageContentMode = TTImageViewContentModeScaleAspectFillRemainTop;
            [self.contentView addSubview:imageView];
            imageView;
        });
        
        [self bindWithViewModel];
    }
    [CATransaction commit];
    return self;
}

- (void)layoutSubviews
{
    [UIView setAnimationsEnabled:NO];
    [super layoutSubviews];
    
    self.coverImageView.frame = self.contentView.bounds;
    
    [UIView setAnimationsEnabled:YES];
}

- (void)bindWithViewModel
{
    @weakify(self);
    [RACObserve(self, viewModel.coverImageModel) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [UIView performWithoutAnimation:^{
            ///这里竟然也会导致出现动画
            [self.coverImageView tsv_setImageWithModel:self.viewModel.coverImageModel placeholderImage:nil];
        }];
    }];
}

@end
