//
//  FHMultiMediaVideoCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaVideoCell.h"
#import "FHVideoModel.h"
#import "UIImageView+BDWebImage.h"
#import "FHVideoCoverView.h"

@interface FHMultiMediaVideoCell ()

@property(nonatomic, strong) FHVideoCoverView *coverView;
@property(nonatomic, strong) UIButton *startBtn;
@property(nonatomic, strong) FHMultiMediaItemModel *model;

@end

@implementation FHMultiMediaVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.contentView.backgroundColor = [UIColor blackColor];
        self.contentView.clipsToBounds = YES;
    }
    return self;
}

- (void)updateViewModel:(FHMultiMediaItemModel *)model {
    
    if (model && !self.isShowenPictureVC) {
        self.model = model;
        self.playerView = model.playerView;
        [self showCoverView];
    }
}

- (void)setPlayerView:(UIView *)playerView {
    if(_playerView){
        [_playerView removeFromSuperview];
        _playerView = nil;
    }
    _playerView = playerView;
    [self.contentView addSubview:_playerView];
}

- (void)showCoverView
{
    if (self.coverView) {
        [self.contentView bringSubviewToFront:self.coverView];
    } else {

        self.coverView = [[FHVideoCoverView alloc] init];
        CGFloat photoCellHeight = 281.0;
        photoCellHeight = round([UIScreen mainScreen].bounds.size.width / 375.0f * photoCellHeight + 0.5);
        [self.coverView setFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, photoCellHeight)];
        //    self.coverView.houseType = self.model.cellHouseType;
        [_coverView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
        _coverView.startBtn.userInteractionEnabled = NO;
        [self.contentView addSubview:_coverView];
    }
    
    NSString *placeHolderImageUrl = [self.model.imageUrl stringByReplacingOccurrencesOfString:@"/origin/" withString:@"/large/"];
    NSString *key = [[BDWebImageManager sharedManager]  requestKeyWithURL:[NSURL URLWithString:placeHolderImageUrl]];
    UIImage *placeHolder = [[BDWebImageManager sharedManager].imageCache imageForKey:key];
    
    if (self.model.imageUrl) {
        [self.coverView showWithImageUrl:self.model.imageUrl placeHoder:placeHolder];
    }
}

@end
