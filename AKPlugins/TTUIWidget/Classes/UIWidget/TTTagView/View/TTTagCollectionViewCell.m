//
//  TTTagCollectionViewCell.m
//  Article
//
//  Created by fengyadong on 16/5/25.
//
//

#import "TTTagCollectionViewCell.h"
#import "SSThemed.h"
#import "TTTagItem.h"
#import "TTTagButton.h"
#import <Masonry/Masonry.h>

@interface TTTagCollectionViewCell()

@property (nonatomic, strong) TTTagButton *tagTextButton;

@end

@implementation TTTagCollectionViewCell

- (void)setupButtonConstraints {
    [self.contentView addSubview:self.tagTextButton];
    [self.tagTextButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)prepareForReuse {
    [super prepareForReuse];
    [self.tagTextButton setTitle:nil forState:UIControlStateNormal];
}

- (void)updateCellWithTagItem:(TTTagItem *)tagItem {
    [self updateComponentsWithTagItem:tagItem];
}

- (void)updateComponentsWithTagItem:(TTTagItem *)tagItem {
    [self.tagTextButton updateWithTagItem:tagItem];
}

- (void)registerCellButtonClass:(Class)clazz {
    if (self.tagTextButton) {
        return;
    }
    if ([clazz isSubclassOfClass:[TTTagButton class]]) {
        self.tagTextButton = [[clazz alloc] init];
    }
    else {
        self.tagTextButton = [[TTTagButton alloc] init];
    }
    
    [self setupButtonConstraints];
}

+ (CGSize)cellSizeWithTagItem:(TTTagItem *)tagItem maxWidth:(CGFloat)maxWidth{
    CGSize size = [tagItem.text boundingRectWithSize:CGSizeMake(maxWidth - tagItem.padding.left - tagItem.padding.right, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:tagItem.font ?: [UIFont systemFontOfSize:tagItem.fontSize]} context:nil].size;
    CGFloat imageWidth = tagItem.buttonImg ? tagItem.buttonImg.size.width : 0;
    size = CGSizeMake(size.width + tagItem.padding.left + tagItem.padding.right + imageWidth + tagItem.textImageInterval, tagItem.font.pointSize + tagItem.padding.top + tagItem.padding.bottom);
    return size;
}

@end
