//
//  FHMultiMediaVideoCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaVideoCell.h"
#import "FHVideoViewController.h"

@interface FHMultiMediaVideoCell ()

@property(nonatomic, strong) UIImageView *coverView;
@property(nonatomic, strong) UIButton *startBtn;
@property(nonatomic, strong) FHVideoViewController *videoVC;

@end

@implementation FHMultiMediaVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
    }
    return self;
}

- (void)initViews {
    self.contentView.backgroundColor = [UIColor blackColor];
    self.contentView.clipsToBounds = YES;

    self.videoVC = [[FHVideoViewController alloc] init];
    _videoVC.view.frame = self.bounds;
    [self.contentView addSubview:_videoVC.view];
    
//    _coverView = [[UIImageView alloc] initWithFrame:self.bounds];
//    _coverView.contentMode = UIViewContentModeScaleAspectFill;
//    _coverView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
//    [self.contentView addSubview:_coverView];
}

- (void)updateViewModel:(FHMultiMediaItemModel *)model {
    [self.videoVC updateData];
//    NSString *imgStr = model.imageUrl;
//    NSURL *url = [NSURL URLWithString:imgStr];
//    [self.imageView bd_setImageWithURL:url placeholder:self.placeHolder];
}

@end
