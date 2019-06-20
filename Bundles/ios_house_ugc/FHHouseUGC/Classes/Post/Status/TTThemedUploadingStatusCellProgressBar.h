//
//  TTThemedUploadingStatusCellProgressBar.h
//  Article
//
//  Created by 徐霜晴 on 16/10/9.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

@interface TTThemedUploadingStatusCellProgressBar : SSThemedView

- (void)setBackgroundColorThemeKey:(NSString *)backgroundColorThemeKey;
- (void)setForegroundColorThemeKey:(NSString *)foregroundColorThemeKey;

@property (nonatomic, assign, readonly) CGFloat progress;

- (void)setProgress:(CGFloat)progress animated:(BOOL)animated;

@end
