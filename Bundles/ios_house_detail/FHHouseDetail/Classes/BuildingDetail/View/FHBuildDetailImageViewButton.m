//
//  FHBuildDetailImageViewButton.m
//  AKCommentPlugin
//
//  Created by luowentao on 2020/7/28.
//

#import "FHBuildDetailImageViewButton.h"
#import "Masonry/Masonry.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"

@interface FHBuildDetailImageViewButton()

@property (nonatomic, strong) FHBuildingDetailDataItemModel *itemModel;
@property (nonatomic, strong) UIImageView *backgroundImage;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UIImage *selectImage;
@property (nonatomic, strong) UIImage *unSelectImage;
@property (nonatomic, strong) FHBuildingIndexModel *buttonIndex;
@property (nonatomic, assign) CGFloat pointX;
@property (nonatomic, assign) CGFloat pointY;
@property (nonatomic, assign) CGFloat beginWidth;
@property (nonatomic, assign) CGFloat beginHeight;
 

@end

@implementation FHBuildDetailImageViewButton

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        UIImageView *imageView = [[UIImageView alloc] initWithImage:self.unSelectImage];
        [self addSubview:imageView];
        self.backgroundImage = imageView;
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.top.bottom.equalTo(self);
        }];
        UILabel *label = [[UILabel alloc] init];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont themeFontSemibold:12];
        label.textColor = [UIColor themeGray1];
        label.textAlignment = NSTextAlignmentCenter;
        [self addSubview:label];
        self.titleLabel = label;
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_offset(6);
            make.height.mas_offset(17);
            make.left.mas_offset(15);
            make.right.mas_offset(-15);
        }];
        self.isSelected = NO;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(buttonOnClick)];
        [self addGestureRecognizer:gesture];
        
    }
    return self;
}

- (void)updateWithData:(id)data {
    if (data && [data isKindOfClass:[FHBuildingDetailDataItemModel class]]) {
        FHBuildingDetailDataItemModel *model = (FHBuildingDetailDataItemModel *)data;
        self.itemModel = model;
        [self.titleLabel setText:[NSString stringWithFormat:@"%@|%@",model.name,model.saleStatus.content]];
        NSMutableAttributedString *attri = [[NSMutableAttributedString alloc] initWithString:self.titleLabel.text];
        NSRange ran = NSMakeRange(model.name.length, 1);
        [attri addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:10] range:ran];
        self.titleLabel.attributedText = attri;
        [self.titleLabel sizeToFit];
        CGSize itemSize = [self.titleLabel sizeThatFits:CGSizeMake([UIScreen mainScreen].bounds.size.width, 17.0)];
        
        
        self.beginWidth = [model.beginWidth floatValue];
        self.beginHeight = [model.beginHeight floatValue];
        self.pointX = [model.pointX floatValue];
        self.pointY = [model.pointY floatValue];
        self.frame = CGRectMake(self.pointX,self.pointY, itemSize.width + 30.0, 42);
    }
}

- (UIImage *)selectImage {
    if (!_selectImage) {
        UIImage *image = [[UIImage imageNamed:@"building_top_image_orange"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 21, 15) resizingMode:UIImageResizingModeStretch];
        _selectImage = image;
    }
    return _selectImage;
}

- (UIImage *)unSelectImage {
    if (!_unSelectImage) {
        UIImage *image = [[UIImage imageNamed:@"building_top_image_white"] resizableImageWithCapInsets:UIEdgeInsetsMake(5, 15, 21, 15) resizingMode:UIImageResizingModeStretch];
        _unSelectImage = image;
    }
    return _unSelectImage;
}

- (void)setIsSelected:(BOOL)isSelected {
    if (_isSelected == isSelected) {
        return;
    }
    _isSelected = isSelected;
    self.backgroundImage.image = isSelected ? self.selectImage : self.unSelectImage;
    self.titleLabel.textColor = isSelected ? [UIColor themeWhite] : [UIColor themeGray1];
}


- (void)buttonOnClick {
    self.isSelected = !self.isSelected;
    
}

- (void)buttonMoveWithHeight:(CGFloat)nowWidth withHeight:(CGFloat)nowHeight {
    [self.layer setPosition:CGPointMake((nowWidth * self.pointX) / self.beginWidth,(nowHeight * self.pointY) / self.beginHeight)];
}

@end
