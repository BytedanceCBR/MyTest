//
//  TSVActivityEntranceCollectionViewCell.m
//  Article
//
//  Created by 王双华 on 2017/12/1.
//

#import "TSVActivityEntranceCollectionViewCell.h"
#import "TSVAnimatedImageView.h"
#import <ReactiveObjC/ReactiveObjC.h>

@interface TSVActivityEntranceCollectionViewCell()

@property (nonatomic, strong) TSVAnimatedImageView *coverImageView;
@property (nonatomic, strong) CALayer *imageMaskLayer;
@property (nonatomic, strong) SSThemedView *topicImageBackgroundView;
@property (nonatomic, strong) SSThemedImageView *topicImageView;
@property (nonatomic, strong) SSThemedImageView *promotionImageView;
@property (nonatomic, strong) SSThemedLabel *promotionLabel;
@property (nonatomic, strong) SSThemedLabel *activityNameLabel;
@property (nonatomic, strong) SSThemedLabel *participateCountLabel;
@property (nonatomic, strong) SSThemedView *topLineView;
@property (nonatomic, strong) SSThemedView *bottomLineView;

@end

@implementation TSVActivityEntranceCollectionViewCell

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
        
        self.imageMaskLayer = ({
            CALayer *layer = [[CALayer alloc] init];;
            layer.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4].CGColor;
            [self.coverImageView.layer addSublayer:layer];
            layer.hidden = YES;
            layer;
        });
        
        self.promotionImageView =({
            SSThemedImageView *imageView = [[SSThemedImageView alloc] init];
            imageView.imageName = @"tsv_promotion";
            [self.contentView addSubview:imageView];
            imageView.hidden = YES;
            imageView;
        });
        
        self.promotionLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont boldSystemFontOfSize:13];
            label.textColorThemeKey = kColorText10;
            label.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:label];
            label.hidden = YES;
            label;
        });
        
        self.topicImageBackgroundView = ({
            SSThemedView *view = [[SSThemedView alloc] init];;
            view.backgroundColorThemeKey = kColorBackground7;
            [self.contentView addSubview:view];
            view.hidden = YES;
            view;
        });
        
        self.topicImageView = ({
            SSThemedImageView *imageView = [[SSThemedImageView alloc] init];
            [self.contentView addSubview:imageView];
            imageView;
        });
        
        self.activityNameLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.textColorThemeKey = kColorText10;
            label.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:label];
            label;
        });
        
        self.participateCountLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] init];
            label.font = [UIFont systemFontOfSize:12];
            label.textColorThemeKey = kColorText10;
            label.textAlignment = NSTextAlignmentCenter;
            [self.contentView addSubview:label];
            label;
        });
        
        self.topLineView = ({
            SSThemedView *view = [[SSThemedView alloc] init];
            view.backgroundColorThemeKey = kColorText10;
            view.alpha = 0.7;
            view.layer.cornerRadius = 1;
            [self.contentView addSubview:view];
            view.hidden = YES;
            view;
        });
        
        self.bottomLineView = ({
            SSThemedView *view = [[SSThemedView alloc] init];
            view.backgroundColorThemeKey = kColorText10;
            view.alpha = 0.7;
            view.layer.cornerRadius = 1;
            [self.contentView addSubview:view];
            view.hidden = YES;
            view;
        });
        
        [self bindWithViewModel];
    }
    [CATransaction commit];
    return self;
}

- (void)layoutSubviews
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [super layoutSubviews];
    
    //不同style 封面图 和推广标签布局相同
    //封面图
    self.coverImageView.frame = self.contentView.bounds;
    self.imageMaskLayer.frame = self.coverImageView.bounds;
    CGFloat width = self.contentView.bounds.size.width;
    CGFloat height = self.contentView.bounds.size.height;
    CGFloat centerX = width / 2;
    CGFloat contentMaxWidth = width - 16;
    
    //推广标签
    CGFloat promotionImageViewHeight = 25;
    CGFloat promotionLabelLeft = 4;
    [self.promotionLabel sizeToFit];
    self.promotionLabel.width = MIN(self.promotionLabel.width, contentMaxWidth);
    self.promotionLabel.left = promotionLabelLeft;
    self.promotionLabel.centerY = promotionImageViewHeight / 2;
    
    CGFloat promotionImageViewWidth = promotionLabelLeft + self.promotionLabel.width + 15;
    self.promotionImageView.frame = CGRectMake(0, 0, promotionImageViewWidth, promotionImageViewHeight);
    
    // # 图片的宽高固定
    self.topicImageView.width = 14;
    self.topicImageView.height = 14;
    
    CGFloat activityNamelabelHeight = 23;
    CGFloat activityNamelabelTopPadding = 6;
    CGFloat activityNamelabelBottomPadding = 6;
    
    CGFloat lineHeight = 2;
    
    CGFloat participateCountLabelHeight = 14;
    
    if (self.viewModel.style == TSVActivityEntranceStyleA) {
        self.topicImageView.imageName = @"tsv_white_jing";
        CGFloat topicImageBackgroundViewSide = 30;
        CGFloat contentHeight = topicImageBackgroundViewSide + 10 + activityNamelabelHeight + activityNamelabelBottomPadding + lineHeight + 8 + participateCountLabelHeight;
        CGFloat top = (height - contentHeight) / 2;
        // #
        self.topicImageBackgroundView.layer.cornerRadius = topicImageBackgroundViewSide / 2;
        self.topicImageBackgroundView.frame = CGRectMake(0, top, topicImageBackgroundViewSide, topicImageBackgroundViewSide);
        self.topicImageBackgroundView.centerX = centerX;
        self.topicImageView.center = self.topicImageBackgroundView.center;
        top += topicImageBackgroundViewSide + 10;
        
        //活动名称
        self.activityNameLabel.font = [UIFont boldSystemFontOfSize:19];
        [self.activityNameLabel sizeToFit];
        self.activityNameLabel.width = MIN(self.activityNameLabel.width, contentMaxWidth);
        self.activityNameLabel.height = activityNamelabelHeight;
        self.activityNameLabel.centerX = centerX;
        self.activityNameLabel.top = top;
        top += activityNamelabelHeight + activityNamelabelBottomPadding;
        
        //分割线
        self.bottomLineView.width = self.activityNameLabel.width;
        self.bottomLineView.height = lineHeight;
        self.bottomLineView.top = top;
        self.bottomLineView.centerX = centerX;
        top += lineHeight + 8;
        
        //参与人数
        [self.participateCountLabel sizeToFit];
        self.participateCountLabel.width = MIN(self.participateCountLabel.width, contentMaxWidth);
        self.participateCountLabel.height = participateCountLabelHeight;
        self.participateCountLabel.centerX = centerX;
        self.participateCountLabel.top = top;
        
        self.promotionImageView.hidden = NO;
        self.promotionLabel.hidden = NO;
        self.topicImageBackgroundView.hidden = NO;
        self.imageMaskLayer.hidden = NO;
        self.topLineView.hidden = YES;
        self.bottomLineView.hidden = NO;
    } else if (self.viewModel.style == TSVActivityEntranceStyleB) {
        self.topicImageView.imageName = @"tsv_white_jing";
        //顶部分割线
        CGFloat contentHeight = lineHeight + activityNamelabelTopPadding + activityNamelabelHeight + activityNamelabelTopPadding + lineHeight;
        CGFloat top = (height - contentHeight) / 2;
        
        self.topLineView.top = top;
        self.topLineView.height = lineHeight;
        top += lineHeight + activityNamelabelTopPadding;
        
        self.activityNameLabel.font = [UIFont boldSystemFontOfSize:19];
        [self.activityNameLabel sizeToFit];
        self.activityNameLabel.width = MIN(self.activityNameLabel.width, contentMaxWidth - 18);
        self.activityNameLabel.height = activityNamelabelHeight;
        self.activityNameLabel.top = top;
        
        self.topicImageView.centerY = self.activityNameLabel.centerY;
        CGFloat contentWidth = 18 + self.activityNameLabel.width;
        self.topicImageView.left = (width - contentWidth) / 2;
        self.activityNameLabel.left = self.topicImageView.right + 4;
        
        top += activityNamelabelHeight;
        top += activityNamelabelBottomPadding;
        
        
        self.bottomLineView.top = top;
        self.bottomLineView.width = contentWidth;
        self.bottomLineView.height = lineHeight;
        self.bottomLineView.centerX = centerX;
        
        self.topLineView.width = contentWidth;
        self.topLineView.centerX = centerX;
        
        //参与人数
        [self.participateCountLabel sizeToFit];
        self.participateCountLabel.width = MIN(self.participateCountLabel.width, contentMaxWidth);
        self.participateCountLabel.height = participateCountLabelHeight;
        self.participateCountLabel.centerX = centerX;
        self.participateCountLabel.bottom = height - 9;
        
        self.promotionImageView.hidden = NO;
        self.promotionLabel.hidden = NO;
        self.topicImageBackgroundView.hidden = YES;
        self.imageMaskLayer.hidden = NO;
        self.topLineView.hidden = NO;
        self.bottomLineView.hidden = NO;
    } else {
        self.topicImageView.imageName = @"tsv_white_jing";
        //参与人数
        [self.participateCountLabel sizeToFit];
        self.participateCountLabel.width = MIN(self.participateCountLabel.width, contentMaxWidth);
        self.participateCountLabel.height = participateCountLabelHeight;
        self.participateCountLabel.centerX = centerX;
        self.participateCountLabel.bottom = height - 9;
        
        self.activityNameLabel.font = [UIFont boldSystemFontOfSize:18];
        [self.activityNameLabel sizeToFit];
        self.activityNameLabel.width = MIN(self.activityNameLabel.width, contentMaxWidth - 18);
        self.activityNameLabel.height = activityNamelabelHeight;
        self.activityNameLabel.bottom = self.participateCountLabel.top - 6;
        
        self.topicImageView.centerY = self.activityNameLabel.centerY;
        CGFloat contentWidth = 18 + self.activityNameLabel.width;
        self.topicImageView.left = (width - contentWidth) / 2;
        self.activityNameLabel.left = self.topicImageView.right + 4;
        
        self.promotionImageView.hidden = YES;
        self.promotionLabel.hidden = YES;
        self.topicImageBackgroundView.hidden = YES;
        self.imageMaskLayer.hidden = YES;
        self.topLineView.hidden = YES;
        self.bottomLineView.hidden = YES;
    }
    
    [CATransaction commit];
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
    RAC(self, promotionLabel.text) = RACObserve(self, viewModel.activityPromotionText);
    RAC(self, activityNameLabel.text) = RACObserve(self, viewModel.activityNameText);
    RAC(self, participateCountLabel.text) = RACObserve(self, viewModel.participateCountText);
    [RACObserve(self, viewModel.style) subscribeNext:^(id  _Nullable x) {
        @strongify(self);
        [self setNeedsLayout];
    }];
}

@end
