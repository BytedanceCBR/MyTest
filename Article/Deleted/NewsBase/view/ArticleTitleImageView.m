//
//  ArticleTitleImageView.m
//  Article
//
//  Created by Dianwei on 13-1-22.
//
//

#import "ArticleTitleImageView.h"
#import "UIColor+TTThemeExtension.h"
#import "TTThemeConst.h"

@interface ArticleTitleImageView ()
@property(nonatomic, retain)NSString * bottomLineColorName;
@end

@implementation ArticleTitleImageView

- (void)dealloc
{
    self.bottomLineColorName = nil;
    self.bottomLineView = nil;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {

    }
    return self;
}


- (void)themeChanged:(NSNotification *)notification
{
    switch (_titleUItype) {
        case ArticleTitleImageViewUITypeDetailView:
        {
            [super themeChanged:notification];
            self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"f6f7f7" nightColorName:@"2b2b2b"]];
            self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText2];
        }
            break;
        case ArticleTitleImageViewUITypeExplore:
        {
            [super themeChanged:notification];
            self.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] selectFromDayColorName:@"f6f7f7" nightColorName:@"2b2b2b"]];
            self.titleLabel.textColor = [UIColor tt_themedColorForKey:kColorText2];
            [self setBottomLineColorName:kColorBackground300];
            self.titleLabel.font = [UIFont boldSystemFontOfSize:18];
        }
            break;
        case ArticleTitleImageViewUITypeDefault:
        {
            [super themeChanged:notification];
            self.titleLabel.textColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt]selectFromDayColorName:@"fafafa" nightColorName:@"b1b1b1"]];
        }
            break;
        case ArticleTitleImageViewUITypeNone:
        {
        }
            break;
    }

    if (_bottomLineColorName != nil) {
        self.bottomLineView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:_bottomLineColorName]];
    }
    else {
        self.bottomLineView.backgroundColor = [UIColor clearColor];
    }

    
}

- (void)setTitleUItype:(ArticleTitleImageViewUIType)titleUItype
{
    _titleUItype = titleUItype;
    [self reloadThemeUI];
}

- (void)setBottomLineColorName:(NSString *)name
{
    if(_bottomLineColorName != name)
    {
        _bottomLineColorName = name;
        self.bottomLineView.backgroundColor = [UIColor colorWithHexString:[[TTThemeManager sharedInstance_tt] rgbaValueForKey:name]];
    }
}


- (void)relayout
{
    [super relayout];
    
}
@end
