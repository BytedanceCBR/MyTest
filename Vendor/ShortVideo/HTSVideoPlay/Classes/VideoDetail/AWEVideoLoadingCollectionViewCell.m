//
//  AWEVideoLoadingCollectionViewCell.m
//  Pods
//
//  Created by Zuyang Kou on 29/06/2017.
//
//

#import "AWEVideoLoadingCollectionViewCell.h"
#import "NSObject+FBKVOController.h"
#import "EXTKeyPathCoding.h"
#import "UIViewAdditions.h"
#import <extobjc.h>

@interface AWEVideoLoadingCollectionViewCell ()

@property (nonatomic, strong) UIImageView *loadingIndicatorView;
@property (nonatomic, strong) UIView *failureContainerView;
@property (nonatomic, strong) UILabel *failureLabel;
@property (nonatomic, strong) UIButton *retryButton;
@property (nonatomic, strong) UIButton *closeButton;

@end

@implementation AWEVideoLoadingCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        self.loadingIndicatorView = [[UIImageView alloc] init];
        self.loadingIndicatorView.image = [UIImage imageNamed:@"hts_video_loading"];
        [self.contentView addSubview:self.loadingIndicatorView];

        self.failureContainerView = [[UIView alloc] init];
        [self.contentView addSubview:self.failureContainerView];

        self.closeButton = [[UIButton alloc] init];
        [self.closeButton setImage:[UIImage imageNamed:@"hts_vp_close"] forState:UIControlStateNormal];
        [self.closeButton setImageEdgeInsets:UIEdgeInsetsMake(8, 0, 8, 0)];
        [self.closeButton addTarget:self action:@selector(handleCloseClick:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.closeButton];


        self.failureLabel = [[UILabel alloc] init];
        self.failureLabel.text = @"视频加载失败";
        self.failureLabel.font = [UIFont systemFontOfSize:14];
        self.failureLabel.textColor = [UIColor whiteColor];
        [self.failureContainerView addSubview:self.failureLabel];

        self.retryButton = [[UIButton alloc] init];
        [self.retryButton setTitle:@"点击重试" forState:UIControlStateNormal];
        self.retryButton.titleLabel.font = [UIFont systemFontOfSize:14];
        [self.retryButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.retryButton addTarget:self action:@selector(retry:) forControlEvents:UIControlEventTouchUpInside];
        self.retryButton.layer.borderWidth = 1;
        self.retryButton.layer.borderColor = [[UIColor whiteColor] CGColor];
        self.retryButton.layer.cornerRadius = 4;
        [self.failureContainerView addSubview:self.retryButton];

        [self startLoading];
    }

    return self;
}

- (void)setDataFetchManager:(id<TSVShortVideoDataFetchManagerProtocol>)dataFetchManager
{
    _dataFetchManager = dataFetchManager;
    
    @weakify(self);
    [self.KVOController unobserveAll];
    [self.KVOController observe:self.dataFetchManager
                        keyPath:@keypath(self.dataFetchManager, isLoadingRequest)
                        options:NSKeyValueObservingOptionNew
                          block:^(id  _Nullable observer, id  _Nonnull object, NSDictionary<NSString *,id> * _Nonnull change) {
                              @strongify(self);
                              if (![self.dataFetchManager isLoadingRequest]) {
                                  [self loadFailed];
                              } else {
                                  [self startLoading];
                              }
                          }];
}

- (IBAction)retry:(id)sender
{
    if (self.retryBlock) {
        self.retryBlock();
    }
}

- (void)startLoading
{
    self.loadingIndicatorView.hidden = NO;
    self.failureContainerView.hidden = YES;

    [self.loadingIndicatorView.layer removeAllAnimations];
    CABasicAnimation *rotateAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.duration = 1.0f;
    rotateAnimation.repeatCount = CGFLOAT_MAX;
    rotateAnimation.toValue = @(M_PI * 2);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.loadingIndicatorView.layer addAnimation:rotateAnimation forKey:@"rotateAnimation"];
    });
}

- (void)loadFailed
{
    self.loadingIndicatorView.hidden = YES;
    self.failureContainerView.hidden = NO;

    [self.loadingIndicatorView.layer removeAllAnimations];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGSize failtureLabelSize = [self.failureLabel sizeThatFits:CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX)];
    CGSize retryButtonSize = CGSizeMake(72, 28);
    CGSize failtureContainerSize = CGSizeMake(MAX(failtureLabelSize.width, retryButtonSize.width),
                                              failtureLabelSize.height + 14 + retryButtonSize.height);
    self.failureContainerView.frame = CGRectMake(0, 0, failtureContainerSize.width, failtureContainerSize.height);
    self.failureContainerView.center = self.contentView.center;

    self.failureLabel.frame = CGRectMake(0, 0, failtureLabelSize.width, failtureLabelSize.height);
    self.retryButton.bounds = CGRectMake(0, 0, retryButtonSize.width, retryButtonSize.height);
    self.retryButton.center = CGPointMake(failtureContainerSize.width / 2, failtureContainerSize.height - retryButtonSize.height / 2);

    self.loadingIndicatorView.bounds = CGRectMake(0, 0, 60, 60);
    self.loadingIndicatorView.center = self.contentView.center;

    self.closeButton.frame = CGRectMake(12, self.tt_safeAreaInsets.top, 30, 48);
}

- (IBAction)handleCloseClick:(id)sender
{
    if (self.closeButtonDidClick) {
        self.closeButtonDidClick();
    }
}

@end
