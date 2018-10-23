//
//  TTHighlightedLabel.m
//  Article
//
//  Created by 王双华 on 16/10/23.
//
//

#import "TTHighlightedLabel.h"

@implementation TTHighlightedLabel

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateContentWithHighlightColor];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateContentWithNormalColor];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self updateContentWithNormalColor];
}

- (void)updateContentWithHighlightColor
{
    UIColor *highlightColor = [UIColor tt_themedColorForKey:self.highlightedBackgroundColorThemeKey];
    self.backgroundColor = highlightColor;
}

- (void)updateContentWithNormalColor
{
    UIColor *normalColor = [UIColor tt_themedColorForKey:self.backgroundColorThemeKey];
    self.backgroundColor = normalColor;
}

@end
