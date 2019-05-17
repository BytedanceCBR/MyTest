//
//  FHMultiMediaVideoCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaVideoCell.h"
#import "FHVideoModel.h"
#import "UIImageView+BDWebImage.h"

@interface FHMultiMediaVideoCell ()

@property(nonatomic, strong) UIImageView *coverView;
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

@end
