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
#import "FHDetailMediaHeaderCell.h"

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
        
        if (model.cellHouseType == FHMultiMediaCellHouseNeiborhood || model.cellHouseType == FHMultiMediaCellHouseSecond) {
            [self showCoverView];
        }
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
        [self bringSubviewToFront:self.coverView];
    }
    
    self.coverView = [[FHVideoCoverView alloc] init];
    [self.coverView setFrame:CGRectMake(0.0, 0.0, [UIScreen mainScreen].bounds.size.width, [FHDetailMediaHeaderCell cellHeight])];
    self.coverView.houseType = self.model.cellHouseType;
    [_coverView setBackgroundColor:[UIColor colorWithRed:1 green:1 blue:1 alpha:1]];
    _coverView.startBtn.enabled = NO;
    [self.contentView addSubview:_coverView];
    
    NSString *placeHolderImageUrl = [self.model.imageUrl stringByReplacingOccurrencesOfString:@"/origin/" withString:@"/large/"];
    NSString *key = [[BDWebImageManager sharedManager]  requestKeyWithURL:[NSURL URLWithString:placeHolderImageUrl]];
    UIImage *placeHolder = [[BDWebImageManager sharedManager].imageCache imageForKey:key];
    
    if (self.model.imageUrl) {
        [self.coverView showWithImageUrl:self.model.imageUrl placeHoder:placeHolder];
    }
}

@end
