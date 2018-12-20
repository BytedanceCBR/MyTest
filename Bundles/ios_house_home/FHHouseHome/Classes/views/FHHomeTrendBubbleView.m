//
//  FHHomeTrendBubbleView.m
//  Article
//
//  Created by 张静 on 2018/11/23.
//

#import "FHHomeTrendBubbleView.h"
#import "UIColor+Theme.h"
#import "UIFont+House.h"
#import "UIViewAdditions.h"

@interface FHHomeTrendBubbleView ()

@property(nonatomic, strong) UIView *bg;

@property(nonatomic, strong) UIImageView *bgView;
@property(nonatomic, strong) UILabel *titleLabel;

@property(nonatomic, copy) FHHomeTrendBubbleViewActionBlock actionBlock;

@end


@implementation FHHomeTrendBubbleView

-(instancetype)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI {

    [self addSubview:self.bgView];
    [self.bgView addSubview:self.titleLabel];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:tapGesture];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    [self addGestureRecognizer:pan];
}


-(void)updateTitle:(NSString *)title {
    
    self.titleLabel.text = title;
}

-(void)showFromView:(UIView *)view withDissmissAction:(FHHomeTrendBubbleViewActionBlock)actionBlock {

    _actionBlock = actionBlock;
    
    UIWindow *keyWindow = [[UIApplication sharedApplication]delegate].window;
    CGPoint newPoint = [view.superview convertPoint:view.origin toView:keyWindow];
    
    self.frame = keyWindow.bounds;
    
    self.bg.frame = keyWindow.bounds;
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self.bg addGestureRecognizer:tapGesture];

    [keyWindow addSubview: self];
    
    [self.bg sizeToFit];
    self.bgView.origin = CGPointMake(16, newPoint.y + view.height);
    self.titleLabel.width = self.bgView.width - 20;
    [self.titleLabel sizeToFit];
    self.titleLabel.top = 15;
    self.titleLabel.left = 10;
    
//    self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);
    [UIView animateWithDuration:0.25f animations:^{
        self.bgView.alpha = 1.f;
        self.alpha = 1.f;
//        self.transform = CGAffineTransformIdentity;
    }];
    
}

-(void)panAction:(UIPanGestureRecognizer *)pan {
    
    [self dismiss];
}

-(void)dismiss {
    
    [UIView animateWithDuration:0.25f animations:^{
        self.alpha = 0.f;
//        self.transform = CGAffineTransformMakeScale(0.01f, 0.01f);

    } completion:^(BOOL finished) {

        [self removeFromSuperview];
        if (self.actionBlock) {
            self.actionBlock();
        }
    }];
    
}

-(UIView *)bg {
    
    if (!_bg) {
        
        _bg = [[UIView alloc]init];
    }
    return _bg;
}

-(UIImageView *)bgView {
    
    if (!_bgView) {
        
        _bgView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"home_bubble_bg"]];
        _bgView.contentMode = UIViewContentModeScaleToFill;
        _bgView.clipsToBounds = true;
    }
    return _bgView;
}

-(UILabel *)titleLabel {
    
    if (!_titleLabel) {
        
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.font = [UIFont themeFontRegular:10];
        _titleLabel.textColor = [UIColor colorWithHexString:@"#092034"];
        _titleLabel.numberOfLines = 0;
        
    }
    return _titleLabel;
}

@end
