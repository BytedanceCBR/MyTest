//
//  TTImagePickerBottomView.m
//  Article
//
//  Created by tyh on 2017/4/11.
//
//

#import "TTImagePickerBottomView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTImagePickerDefineHead.h"
#import "UIView+TTImagePickerBlur.h"
#import "SSThemed.h"
#import "UIViewAdditions.h"
#import "TTThemeManager.h"

@interface TTImagePickerBottomView()
{
    UILabel *previewLabel;
    UIView *previewTouch;
    int seletedCount;

}

@property (nonatomic,assign)BOOL isSeletedImg;


@end

@implementation TTImagePickerBottomView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        seletedCount = 0;
        [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(selectedCountDidChange:) name:TTImagePickerSelctedCountDidChange object:nil];

        [self _initViews];
    }
    return self;
}


- (void)_initViews
{
    UIView *line = [[UIView alloc]initWithFrame:CGRectMake(0, 0, self.width, 0.5)];
    line.backgroundColor = [UIColor tt_themedColorForKey:kColorLine10];
    [self addSubview:line];
    
    self.backgroundColor = [UIColor tt_themedColorForKey:kColorBackground4];
    
    previewLabel = [[UILabel alloc]initWithFrame:CGRectMake(self.width - 32 - 15, 15, 35, 16)];
    previewLabel.text = @"预览";
    previewLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];
    previewLabel.font = [UIFont systemFontOfSize:16];
    [self addSubview:previewLabel];
    
    previewTouch = [[UIView alloc]initWithFrame:CGRectMake(self.width - 84, 0, 84, self.height)];
    [self addSubview:previewTouch];

    UITapGestureRecognizer *previewtap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(previewTapAction)];
    [previewTouch addGestureRecognizer:previewtap];
}

#pragma mark - Action
- (void)previewTapAction
{
    if (seletedCount <= 0 ) {
        return;
    }
    
    if (self.previewAction != nil) {
        self.previewAction();
    }
}

#pragma mark - Notify

- (void)selectedCountDidChange:(NSNotification *)notify
{
    if ([notify.object intValue] <= 0) {
        previewLabel.textColor = [UIColor tt_themedColorForKey:kColorText9];;
    }else{
        if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight) {
            previewLabel.textColor = [UIColor tt_themedColorForKey:kColorText6];
        }else{
            previewLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
        }
    }
    seletedCount = [notify.object intValue];
    
    
    
}

- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}




@end
