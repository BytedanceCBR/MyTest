//
//  TTImagePreviewTopBar.m
//  Article
//
//  Created by SongChai on 2017/4/9.
//
//

#import "TTImagePreviewTopBar.h"
#import <Masonry.h>
#import "UIView+TTImagePickerBlur.h"
#import "TTImagePickerDefineHead.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"

@interface TTImagePreviewTopBar()
{
}
@property(nonatomic, strong) UILabel* numLabel;

@property(nonatomic, strong) UIButton* closeButton;
@property(nonatomic, strong) UILabel* titleLabel;
@property(nonatomic, strong) UIButton* deleteButton;
@property(nonatomic, strong) UIButton* completeButton;
@end

@implementation TTImagePreviewTopBar

- (instancetype)initWithFrame:(CGRect)frame withType:(TTImagePreviewType)type
{
    self = [super initWithFrame:frame];
    if (self) {
        [self _initViewsWithType:type];
    }
    return self;
}

- (void)_initViewsWithType:(TTImagePreviewType)type
{
    self.backImg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.width, self.height)];
    self.backImg.image = [UIImage imageNamed:@"ImgPic_on_masked"];
    [self addSubview:self.backImg];
    
    float adaptXHeight = [TTDeviceHelper isIPhoneXDevice] ? TTSafeAreaInsetsTop : 0;
    
    if (type == TTImagePreviewTypeDelete) {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake((self.width - 70)/2.0,( 50-18)/2.0 + adaptXHeight, 70, 18)];
        self.titleLabel.numberOfLines = 1;
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.titleLabel];
    }
  

    UIButton* leftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [leftButton setImage:[UIImage imageNamed:@"ImgPic_close"] forState:UIControlStateNormal];
    leftButton.tintColor = [UIColor whiteColor];
    leftButton.frame = CGRectMake(12, 13 + adaptXHeight, 24, 24);
    [leftButton addTarget:self action:@selector(onClickClose) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:leftButton];
    self.closeButton = leftButton;
    
    UIButton* rightButton = nil;
    if (type == TTImagePreviewTypeDelete) {
        rightButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [rightButton setImage:[UIImage imageNamed:@"ImgPic_delete_release"] forState:UIControlStateNormal];
        rightButton.frame = CGRectMake(self.width - 24 - 12, 13 + adaptXHeight, 24, 24);

        leftButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
        [rightButton addTarget:self action:@selector(onClickDelete) forControlEvents:UIControlEventTouchUpInside];
        
        self.deleteButton = rightButton;
    } else {
        rightButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        rightButton.frame = CGRectMake(self.width - 32 - 15, 15 + adaptXHeight, 35, 16);
        [rightButton setTitle:@"完成" forState:0];
        [rightButton setTitleColor:[UIColor whiteColor] forState:0];
        rightButton.titleLabel.font = [UIFont boldSystemFontOfSize:16];
        self.completeButton = rightButton;
        [rightButton addTarget:self action:@selector(onClicComplete) forControlEvents:UIControlEventTouchUpInside];
        rightButton.centerY = leftButton.centerY;
        
        if (type == TTImagePreviewTypeDefalut) {
            UILabel *numLabel = [[UILabel alloc]initWithFrame:CGRectMake(rightButton.left - 20 - 5, 13 + adaptXHeight, 20, 20)];
            numLabel.text = @"0";
            numLabel.hidden = YES;
            numLabel.layer.cornerRadius = 10;
            numLabel.layer.masksToBounds = YES;
            numLabel.textAlignment = NSTextAlignmentCenter;
            numLabel.font = [UIFont systemFontOfSize:15];
            numLabel.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground8];
            numLabel.textColor = [UIColor whiteColor];
            numLabel.layer.borderColor = [UIColor whiteColor].CGColor;
            numLabel.layer.borderWidth = 1;
            numLabel.centerY = leftButton.centerY;
            self.numLabel = numLabel;
            [self addSubview:numLabel];
        }
       
    }
    
    leftButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    rightButton.hitTestEdgeInsets = UIEdgeInsetsMake(-20, -20, -20, -20);
    
    [self addSubview:rightButton];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedCountDidChange:) name:TTImagePickerSelctedCountDidChange object:nil];

    
}


- (void)setSelectedCount:(int)selectedCount
{
    _selectedCount = selectedCount;
    
    if (_selectedCount <= 0) {
        self.numLabel.hidden = YES;
    }else{
        self.numLabel.hidden = NO;
        self.numLabel.text = [NSString stringWithFormat:@"%d",_selectedCount];
        //小动画
        self.numLabel.transform = CGAffineTransformMakeScale(0.2, 0.2);
        [UIView animateWithDuration:0.5 delay:0 usingSpringWithDamping:0.5 initialSpringVelocity:1 options:UIViewAnimationOptionCurveLinear animations:^{
            self.numLabel.transform = CGAffineTransformMakeScale(1, 1);
        } completion:nil];
    }

}




- (void)setTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (NSString *)title {
    return self.titleLabel.text;
}

#pragma -- mark private
- (void) onClickClose {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewTopBarOnButtonClick:)]) {
        [self.delegate ttImagePreviewTopBarOnButtonClick:TTImagePreviewTopBarButtonTagClose];
    }
}

- (void) onClicComplete {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewTopBarOnButtonClick:)]) {
        [self.delegate ttImagePreviewTopBarOnButtonClick:TTImagePreviewTopBarButtonTagComplete];
    }
}

- (void) onClickDelete {
    if (self.delegate && [self.delegate respondsToSelector:@selector(ttImagePreviewTopBarOnButtonClick:)]) {
        [self.delegate ttImagePreviewTopBarOnButtonClick:TTImagePreviewTopBarButtonTagDelete];
    }
}

#pragma mark - Notify

- (void)selectedCountDidChange:(NSNotification *)notify
{

    self.selectedCount = [notify.object intValue];
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
