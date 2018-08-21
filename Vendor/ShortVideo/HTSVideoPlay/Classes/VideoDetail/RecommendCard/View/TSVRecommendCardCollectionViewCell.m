//
//  TSVRecommendCardCollectionViewCell.m
//  HTSVideoPlay
//
//  Created by dingjinlu on 2018/1/15.
//

#import "TSVRecommendCardCollectionViewCell.h"
#import "TSVUserRecommendationModel.h"
#import "TTFollowThemeButton.h"
#import "TSVAvatarImageView.h"
#import "ReactiveObjC.h"
#import "UIViewAdditions.h"
#import "TTLabelTextHelper.h"
#import "TSVUserRecommendationViewModel.h"

@interface TSVRecommendCardCollectionViewCell()

@property (nonatomic, strong) TTFollowThemeButton *followButton;
@property (nonatomic, strong) SSThemedLabel *nameLabel;
@property (nonatomic, strong) SSThemedLabel *infoLabel;
@property (nonatomic, strong) TSVAvatarImageView *avatarView;
@property (nonatomic, strong) UIVisualEffectView *blurView;
@end

@implementation TSVRecommendCardCollectionViewCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.blurView = ({
            UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            UIVisualEffectView *view = [[UIVisualEffectView alloc]initWithEffect:effect];
            view.clipsToBounds = YES;
            view.layer.cornerRadius = 4;
            view.userInteractionEnabled = NO;
            view;
        });
        [self addSubview:self.blurView];
        
        self.followButton = ({
            TTFollowThemeButton *button = [[TTFollowThemeButton alloc] initWithUnfollowedType:TTUnfollowedType101
                                                                                 followedType:TTFollowedType103
                                                                           followedMutualType:TTFollowedMutualType103];
            [button addTarget:self action:@selector(handleFollowClick:) forControlEvents:UIControlEventTouchUpInside];
            button.forbidNightMode = YES;
            button.hidden = NO;
            button;
        });
        [self addSubview:self.followButton];
        
        self.nameLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, self.width - 24, 20)];
            label.font = [UIFont boldSystemFontOfSize:14];
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 1;
            label.textAlignment = NSTextAlignmentCenter;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.userInteractionEnabled = NO;
            label;
        });
        [self addSubview:self.nameLabel];
        
        self.infoLabel = ({
            SSThemedLabel *label = [[SSThemedLabel alloc] initWithFrame:CGRectMake(0, 0, self.width - 24, 34)];
            label.font = [UIFont systemFontOfSize:12];
            label.textColor = [UIColor whiteColor];
            label.numberOfLines = 2;
            label.textAlignment = NSTextAlignmentCenter;
            label.lineBreakMode = NSLineBreakByTruncatingTail;
            label.userInteractionEnabled = NO;
            label;
        });
        [self addSubview:self.infoLabel];
        
        self.avatarView = ({
            TSVAvatarImageView *avatar = [[TSVAvatarImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)
                                                                             model:self.viewModel.model.user
                                                                  disableNightMode:YES];
            avatar.borderColor = [UIColor whiteColor];
            avatar.borderWidth = 1;
            avatar.userInteractionEnabled = NO;
            avatar;
        });
        [self addSubview:self.avatarView];
        
        @weakify(self);
        [RACObserve(self,viewModel)
         subscribeNext:^(TSVUserRecommendationViewModel *viewModel) {
            @strongify(self);
            [self refreshData];
        }];
        
        RAC(self, followButton.followed, @NO) = RACObserve(self, viewModel.model.user.isFollowing);
        
        [[RACObserve(self, viewModel.isStartFollowLoading)
          deliverOnMainThread]
         subscribeNext:^(id x) {
            @strongify(self);
            BOOL isStartFollowLoading = [x boolValue];
             [UIView performWithoutAnimation:^{
                 if (isStartFollowLoading) {
                     [self.followButton startLoading];
                 } else if(self.followButton.isLoading) {
                     [self.followButton stopLoading:nil];
                 }
             }];
        }];
    }
    return self;
}

- (void)refreshData
{
    self.nameLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.viewModel.model.user.name
                                                                         fontSize:14
                                                                       lineHeight:20
                                                                    lineBreakMode:NSLineBreakByTruncatingTail
                                                                  isBoldFontStyle:YES
                                                                  firstLineIndent:0
                                                                    textAlignment:NSTextAlignmentCenter];

    self.infoLabel.attributedText = [TTLabelTextHelper attributedStringWithString:self.viewModel.model.recommendReason
                                                                         fontSize:12
                                                                       lineHeight:17
                                                                    lineBreakMode:NSLineBreakByTruncatingTail
                                                                  isBoldFontStyle:NO
                                                                  firstLineIndent:0
                                                                    textAlignment:NSTextAlignmentCenter];
    [self.avatarView refreshWithModel:self.viewModel.model.user];
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    [UIView performWithoutAnimation:^{
        
        self.blurView.frame = self.bounds;
        
        self.avatarView.centerX = self.bounds.size.width / 2;
        self.avatarView.top = 12;
        
        CGFloat maxLength = self.bounds.size.width  - 24;
        
        self.nameLabel.width = MIN(self.nameLabel.width, maxLength);
        self.nameLabel.height = 20;
        self.nameLabel.centerX = self.bounds.size.width  / 2;
        self.nameLabel.top = self.avatarView.bottom  + 2;
        
        self.infoLabel.alpha = 0.8;
        self.infoLabel.width = maxLength;
        CGFloat height = [TTLabelTextHelper heightOfText:self.viewModel.model.recommendReason
                                                fontSize:12
                                                forWidth:self.infoLabel.width
                                           forLineHeight:17
                            constraintToMaxNumberOfLines:2
                                         firstLineIndent:0
                                           textAlignment:NSTextAlignmentCenter];
        self.infoLabel.height = MIN(height, 34);
        self.infoLabel.centerX = self.bounds.size.width  / 2;
        self.infoLabel.top = self.nameLabel.bottom + 1;
        
        self.followButton.frame = CGRectMake(12, self.avatarView.bottom + 64, self.bounds.size.width - 24, 28);
    }];
}

- (void)handleFollowClick:(id)sender
{
    [self.viewModel clickFollowButton];
}
     
@end
