//
//  TTVFeedListWebItem.m
//  Article
//
//  Created by panxiang on 2017/4/19.
//
//

#import "TTVFeedListWebItem.h"
#import "TTVFeedWebCellContentView.h"
#import "TTVFeedCellForRowContext.h"
#import "TTVFeedCellWillDisplayContext.h"
#import "TTVFeedCellSelectContext.h"
#import "TTVFeedCellEndDisplayContext.h"

@implementation TTVFeedListWebItem

- (CGFloat)cellHeightWithWidth:(NSInteger)width
{
    return [TTVFeedWebCellContentView obtainHeightForFeed:self cellWidth:ttv_feedContainerWidth(width)];
}

@end


@interface TTVFeedListWebCell ()

@property (nonatomic, strong) TTVFeedWebCellContentView *webContainerView;

@end

@implementation TTVFeedListWebCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _webContainerView = [[TTVFeedWebCellContentView alloc] initWithFrame:CGRectZero];
        [self.containerView addSubview:_webContainerView];
    }
    return self;
}

- (void)setItem:(TTVFeedListWebItem *)item
{
    [super setItem:item];

    self.webContainerView.webItem = item;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    self.webContainerView.frame = self.containerView.bounds;
}

@end

