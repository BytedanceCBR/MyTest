//
//  TTVDetailRelatedMoreItem.m
//  Article
//
//  Created by pei yun on 2017/6/12.
//
//

#import "TTVDetailRelatedMoreItem.h"
#import "TTAlphaThemedButton.h"

@implementation TTVDetailRelatedMoreItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return 44.f;
}

@end

@interface TTVDetailRelatedMoreCell ()

@property (nonatomic, strong) TTAlphaThemedButton *loadMoreButton;

@end


@implementation TTVDetailRelatedMoreCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _loadMoreButton = [TTAlphaThemedButton buttonWithType:UIButtonTypeCustom];
        _loadMoreButton.titleColorThemeKey = kColorText1;
        _loadMoreButton.highlightedTitleColorThemeKey = kColorText1Highlighted;
        _loadMoreButton.userInteractionEnabled = NO;
        
        NSString *title = @"查看更多";
        UIImage *image = [UIImage imageNamed:@"seemore_all"];
        [_loadMoreButton setTitle:title forState:UIControlStateNormal];
        [_loadMoreButton setImage:[UIImage themedImageNamed:@"seemore_all"] forState:UIControlStateNormal];
        [_loadMoreButton setImage:[UIImage themedImageNamed:@"seemore_all_press"] forState:UIControlStateHighlighted];
        _loadMoreButton.titleLabel.font = [UIFont systemFontOfSize:[[self class] loadMoreButtonFontSize]];
        
        CGFloat imageEdgeInset = [[self class] loadMoreButtonFontSize] * [title length] + 8;
        CGFloat titleEdgeInset = image.size.width + 8;
        if ([TTDeviceHelper isPadDevice]) {
            imageEdgeInset += 8;
            titleEdgeInset += 8;
        }
        _loadMoreButton.imageEdgeInsets = UIEdgeInsetsMake(1, imageEdgeInset, -1, -imageEdgeInset);
        _loadMoreButton.titleEdgeInsets = UIEdgeInsetsMake(0, 0, 0, titleEdgeInset);
        [self.contentView addSubview:_loadMoreButton];
        [_loadMoreButton mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.width.height.equalTo(self.contentView);
        }];
    }
    return self;
}

#pragma mark - Helpers

+ (CGFloat)loadMoreButtonFontSize
{
    if ([TTDeviceHelper isPadDevice]) {
        return 18.f;
    }
    return 14.f;
}

@end
