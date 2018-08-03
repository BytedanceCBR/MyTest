//
//  TTImagePreviewBottomView.m
//  Article
//
//  Created by tyh on 2017/4/27.
//
//

#import "TTImagePreviewBottomView.h"
#import "UIViewAdditions.h"
#import "SSThemed.h"
#import "UIImage+TTThemeExtension.h"

@interface TTImagePreviewBottomView()

@property (nonatomic,strong)UIButton *selectButton;

@end


@implementation TTImagePreviewBottomView


- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
    
        [self _initViews];
    }
    return self;
}
- (void)_initViews
{
    self.backImg = [[UIImageView alloc]initWithFrame:self.bounds];
    self.backImg.image = [UIImage imageNamed:@"ImgPic_under_masked"];
    [self addSubview:self.backImg];
    
    self.selectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.selectButton.frame = CGRectMake(self.width- 32 -12, self.height - 32 -12, 32, 32);
    [self.selectButton setImage:[UIImage themedImageNamed:@"ImgPic_select_ok_preview"] forState:UIControlStateSelected];
    [self.selectButton setImage:[UIImage themedImageNamed:@"ImgPic_select_preview"] forState:UIControlStateNormal];
    [self.selectButton addTarget:self action:@selector(onClickSelect) forControlEvents:UIControlEventTouchUpInside];
    self.selectButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    [self addSubview:self.selectButton];
    
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    self.backImg.frame = self.bounds;
}


- (BOOL)isSelected {
    return self.selectButton.isSelected;
}

- (void)setSelected:(BOOL)selected {
    
    if (self.selectButton.selected != selected) {
        if (!self.selectButton.selected) {
            UIImageView *rotateImg = [[UIImageView alloc] initWithFrame:self.selectButton.bounds];
            rotateImg.image = [UIImage themedImageNamed:@"ImgPic_select_ok_preview"];
            rotateImg.transform = CGAffineTransformMakeScale(0.2, 0.2);
            rotateImg.transform = CGAffineTransformRotate(rotateImg.transform, -M_PI/4);
            [self.selectButton addSubview:rotateImg];
            
            [UIView animateWithDuration:0.1 animations:^{
                rotateImg.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                
                [rotateImg removeFromSuperview];
                self.selectButton.selected = selected;
            }];
            
        }else{
            self.selectButton.selected = selected;
        }
    }
    
}
- (void)onClickSelect {
    
    if (self.selectAction) {
        self.selectAction();
    }
    
}

@end
