//
//  ArticleSearchBaseCell.m
//  Article
//
//  Created by SunJiangting on 14-7-7.
//
//

#import "ArticleSearchBaseCell.h"
#import "TTDeviceHelper.h"

@implementation ArticleSearchBaseCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = CGRectMake(0, 0, 320, kArticleSearchBaseCellH);
        self.separatorView = [[UIView alloc] init];
        [self addSubview:self.separatorView];
        
        self.iconView = [[SSThemedImageView alloc] initWithFrame:CGRectMake(14, 13, 18, 18)];
        self.iconView.imageName = @"detail_search_icon";
        self.iconView.alpha = 0.25;
        [self addSubview:self.iconView];
        
        self.keywordLabel = [[UILabel alloc] initWithFrame:CGRectMake(45, 1, 265, kArticleSearchBaseCellH)];
        self.keywordLabel.font = [UIFont systemFontOfSize:16.];
        self.keywordLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.keywordLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.keywordLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.keywordLabel];
        
        self.backgroundColorThemeKey = kColorBackground4;
        if (![SSCommonLogic transitionAnimationEnable]){
            self.backgroundSelectedColorThemeKey = kColorBackground4Highlighted;
        }
        
        [self themeChanged:nil];
    }
    return self;
}

- (void) themeChanged:(NSNotification *)notification {
    [super themeChanged:notification];
    self.separatorView.backgroundColor = [UIColor tt_themedColorForKey:kColorLine1];
//    self.keywordLabel.textColor = [UIColor tt_themedColorForKey:kColorText1];
}

- (void) setFrame:(CGRect)frame {
    [super setFrame:frame];
    self.separatorView.frame = CGRectMake(0, frame.size.height - [TTDeviceHelper ssOnePixel], frame.size.width, [TTDeviceHelper ssOnePixel]);
}

@end
