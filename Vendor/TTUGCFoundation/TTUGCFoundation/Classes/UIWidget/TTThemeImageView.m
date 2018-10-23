 //
//  TTThemeImageView.m
//  Article
//
//  Created by chenjiesheng on 2017/2/8.
//
//

#import "TTThemeImageView.h"
#import "TTCommentImageHelper.h"
#import "TTThemeManager.h"

@implementation TTThemeImageView

- (void)setImageWithModel:(TTImageInfosModel *)model{
    [self updateWithModel:model placeholderImage:nil placeholderView:nil options:0];
    [TTCommentImageHelper setupObjectImageWithInfoModel:model object:self.imageView callback:^(UIImage * _Nullable image) {
        [self themeChanged:nil];
    }];
}

- (void)themeChanged:(NSNotification *)notification{
    if ([TTThemeManager sharedInstance_tt].currentThemeMode == TTThemeModeNight && _enableNightView){
        self.imageView.image = [TTCommentImageHelper nightImageWithOriginImage:self.imageView.image];
    }else{
        self.imageView.image = [TTCommentImageHelper dayImageWithOriginImage:self.imageView.image];
    }
}

@end

