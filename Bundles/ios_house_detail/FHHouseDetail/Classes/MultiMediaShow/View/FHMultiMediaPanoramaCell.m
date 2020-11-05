//
//  FHMultiMediaPanoramaCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/10/29.
//

#import "FHMultiMediaPanoramaCell.h"
#import "UIImageView+BDWebImage.h"

@interface FHMultiMediaPanoramaCell ()

@property(nonatomic , strong) UIImageView *imageView;
@property(nonatomic, strong) UIImageView *startBtn;
@end

@implementation FHMultiMediaPanoramaCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_imageView];
        self.contentView.clipsToBounds = YES;
        self.startBtn = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 50, 50)];
        self.startBtn.image = [UIImage imageNamed:@"detail_panorama_icon"];
        [self.imageView addSubview:_startBtn];
        self.startBtn.center = self.imageView.center;
        
    }
    return self;
}

- (void)updateViewModel:(FHMultiMediaItemModel *)model {
    NSString *imgStr = model.imageUrl;
    NSURL *url = [NSURL URLWithString:imgStr];
    UIImage *placeholder = nil;
    if (model.instantImageUrl) {
        NSString *key = [[BDWebImageManager sharedManager]requestKeyWithURL:[NSURL URLWithString:model.instantImageUrl]];
        placeholder = [[[BDWebImageManager sharedManager] imageCache] imageForKey:key];
    }
    if (!placeholder) {
        placeholder = self.placeHolder;
    }
    [self.imageView bd_setImageWithURL:url placeholder:placeholder];
}

@end
