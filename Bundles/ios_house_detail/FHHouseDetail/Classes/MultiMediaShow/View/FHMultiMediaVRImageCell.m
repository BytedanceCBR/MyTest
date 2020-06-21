//
//  FHMultiMediaVRImageCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/9/26.
//

#import "FHMultiMediaVRImageCell.h"
#import "FHMotionImageView.h"
#import "UIImageView+BDWebImage.h"
#import <BDWebImage/BDWebImageManager.h>

@interface FHMultiMediaVRImageCell()
@property(nonatomic , strong) FHMotionImageView *imageView;
@end

@implementation FHMultiMediaVRImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[FHMotionImageView alloc] initWithFrame:self.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.contentView.backgroundColor = [UIColor whiteColor];
        [self.contentView addSubview:_imageView];
        self.contentView.clipsToBounds = YES;
    }
    return self;
}

- (void)updateViewModel:(FHMultiMediaItemModel *)model {
    NSString *imgStr = model.imageUrl;
    if (imgStr) {
        NSURL *url = [NSURL URLWithString:imgStr];
        if (url) {
            UIImage *placeholder = nil;
            if (model.instantImageUrl) {
                NSString *key = [[BDWebImageManager sharedManager]requestKeyWithURL:[NSURL URLWithString:model.instantImageUrl]];
                placeholder = [[[BDWebImageManager sharedManager] imageCache] imageForKey:key];
            }
            if (!placeholder) {
                placeholder = self.placeHolder;
            }
            
            [self.imageView updateImageUrl:url andPlaceHolder:placeholder];
            self.imageView.cellHouseType = model.cellHouseType;
        }
    }
}

- (void)checkVRLoadingAnimate
{
    [_imageView checkLoadingState];
}

@end
