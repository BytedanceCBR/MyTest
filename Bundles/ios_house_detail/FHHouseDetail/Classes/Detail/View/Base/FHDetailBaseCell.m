//
//  FHDetailBaseCell.m
//  FHHouseDetail
//
//  Created by 张元科 on 2019/1/30.
//

#import "FHDetailBaseCell.h"
@interface FHDetailBaseCell ()
@end

@implementation FHDetailBaseCell

+ (Class)cellViewClass
{
    return [self class];
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.clipsToBounds = YES;
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
}

// element_show 的时候 element_type，返回为空不上报
- (NSString *)elementTypeString:(FHHouseType)houseType {
    return @"";
}

- (NSArray *)elementTypeStringArray:(FHHouseType)houseType
{
    return @[];
}

- (NSDictionary *)elementHouseShowUpload
{
    return @{};
}

- (void)vc_viewDidAppear:(BOOL)animated {
    
}

- (void)vc_viewDidDisappear:(BOOL)animated {
    
}

- (void)fh_willDisplayCell {
    
}

- (void)fh_didEndDisplayingCell{

}

@end

// FHDetailBaseCollectionCell
@implementation FHDetailBaseCollectionCell

+ (Class)cellViewClass
{
    return [self class];
}

+ (CGSize )cellSizeWithData:(id)data width:(CGFloat )width {
    return CGSizeMake(width, 0);
}

+ (NSString *)cellIdentifier {
    return NSStringFromClass([self cellViewClass]);
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.contentView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)refreshWithData:(id)data {
    // sub implements.........
}

@end
