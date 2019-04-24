//
//  FHMultiMediaImageCell.m
//  FHHouseMine
//
//  Created by 谢思铭 on 2019/4/15.
//

#import "FHMultiMediaImageCell.h"
#import <UIImageView+BDWebImage.h>

@interface FHMultiMediaImageCell ()

@property(nonatomic , strong) UIImageView *imageView;

@end

@implementation FHMultiMediaImageCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
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
    NSURL *url = [NSURL URLWithString:imgStr];
    [self.imageView bd_setImageWithURL:url placeholder:self.placeHolder];
}

@end
