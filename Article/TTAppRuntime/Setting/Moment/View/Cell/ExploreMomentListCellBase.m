//
//  ExploreMomentListCellBase.m
//  Article
//
//  Created by Zhang Leonardo on 15-1-14.
//
//

#import "ExploreMomentListCellBase.h"

@interface ExploreMomentListCellBase()

@end

@implementation ExploreMomentListCellBase

- (void)dealloc
{
    self.delegate = nil;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.needMargin = YES;
    }
    return self;
}


+ (CGFloat)heightForModel:(ArticleMomentModel *)model cellWidth:(CGFloat)width sourceType:(ArticleMomentSourceType)sourceType
{
    return 0;
}

- (void)refreshWithModel:(ArticleMomentModel *)model indexPath:(NSIndexPath *)indexPath
{
    self.momentModel = model;
    self.cellIndex = indexPath;
}

- (ArticleMomentModel *)currentModel
{
    return _momentModel;
}

- (void)prepareForReuse
{
    //subview implement
}

@end
