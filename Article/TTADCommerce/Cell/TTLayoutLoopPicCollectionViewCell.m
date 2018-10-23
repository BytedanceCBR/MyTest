//
//  TTLayoutLoopPicCollectionViewCell.m
//  Article
//
//  Created by 曹清然 on 2017/6/20.
//
//

#import "TTLayoutLoopPicCollectionViewCell.h"
#import "ExploreCellBase.h"
#import "TTImageView.h"
#import "TTAsyncCornerImageView.h"
#import "TTArticleCellConst.h"
#import "TTImageView+TrafficSave.h"


@interface TTLayoutLoopPicCollectionViewCell ()

@property (nonatomic,strong) TTImageView *imageView;

@end

@implementation TTLayoutLoopPicCollectionViewCell

-(instancetype)initWithFrame:(CGRect)frame{
    
    self = [super initWithFrame:frame];
    if (self) {
        
        _imageView = [[TTImageView alloc] init];
        _imageView.borderColorThemeKey = kPicViewBorderColor();
        _imageView.backgroundColorThemeKey = kPicViewBackgroundColor();
        _imageView.layer.borderWidth = [TTDeviceHelper ssOnePixel];
        _imageView.imageContentMode = UIViewContentModeScaleAspectFill;
        [self.contentView addSubview:_imageView];
    }
    
    return self;
}

-(void)layoutSubviews{
    [super layoutSubviews];
    _imageView.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
}


-(void)configureWithModel:(TTImageInfosModel *)imageModel{
    
    if (!imageModel) {
        return;
    }
    [self.imageView setImageWithModelInTrafficSaveMode:imageModel placeholderImage:nil];
}



@end
