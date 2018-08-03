//
//  ExploreEmbedGuideCell.m
//  Article
//
//  Created by SunJiangting on 14-9-11.
//
//

#import "ExploreEmbedGuideCell.h"
#import "ExploreCellViewBase.h"
#import "SSImageView.h"
#import "ExploreArticleCellViewConsts.h"
#import "ExploreOrderedData.h"
#import "TTLabelTextHelper.h"

@implementation ExploreEmbedGuideCell {
    __weak UIView * _selectedView;
}

const CGSize ExploreEmbedGuideCellDefaultSize = {320, 50};
const CGFloat ExploreEmbedGuideCellBaseContextTextSize = 17.;

- (instancetype) initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    CGRect frame = CGRectZero;
    frame.size = ExploreEmbedGuideCellDefaultSize;
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.frame = frame;
        self.contentView.frame = frame;
    }
    return self;
}

- (void)refreshWithData:(ExploreOrderedData *)data {
    [super refreshWithData:data];
    self.data = data;
    self.promoteLabel.text = [data displayLabel];
    self.sourceLabel.text = data.persistentAD.source;
    self.titleLabel.text = data.persistentAD.title;
    if (data.persistentAD.imageModel) {
        self.displayImageView.hidden = NO;
        [self.displayImageView setImageWithModel:data.persistentAD.imageModel placeholderImage:nil];
    } else {
        self.displayImageView.hidden = YES;
    }
}

- (void)refreshUI {
    CGFloat basedWidth = self.cellView.width - (ExploreADCellContentInset.left + ExploreADCellContentInset.right);
    CGFloat height = [TTLabelTextHelper heightOfText:self.titleLabel.text fontSize:[[self class] preferredContentTextSize] forWidth:basedWidth];
    
    self.titleLabel.frame = CGRectMake(ExploreADCellContentInset.left, ExploreADCellContentInset.top, basedWidth, height);
    SSImageInfosModel *imageModel = ((ExploreOrderedData *)self.data).persistentAD.imageModel;
    if (imageModel) {
        CGFloat imageWidth = imageModel.width;
        if (imageWidth == 0) {
            imageWidth = 570;
        }
        CGFloat imageHeight = ceilf(basedWidth * (imageModel.height/imageWidth));
        self.displayImageView.frame = CGRectMake(15, self.titleLabel.bottom + 10, basedWidth, imageHeight);
        self.bottomView.frame = CGRectMake(0, self.displayImageView.bottom + 10, self.cellView.width, 25);
    } else {
        /// 无图
        CGFloat margin = 5;
        self.titleLabel.top = (self.height - (self.titleLabel.height + margin + 12)) / 2;
        self.bottomView.frame = CGRectMake(0, self.titleLabel.bottom + margin, self.cellView.width, 12);
    }

    [super refreshUI];
}

+ (CGFloat) heightForData:(ExploreOrderedData *) data cellWidth:(CGFloat)width listType:(ExploreOrderedDataListType)cellType {
    CGFloat basedWidth = (width - (ExploreADCellContentInset.left + ExploreADCellContentInset.right));
    CGFloat height = [TTLabelTextHelper heightOfText:data.persistentAD.title fontSize:[self preferredContentTextSize] forWidth:basedWidth];
    if (data.persistentAD.imageModel) {
        CGFloat imageWidth = data.persistentAD.imageModel.width;
        if (imageWidth == 0) {
            imageWidth = 570;
        }
        height += ceilf(basedWidth * data.persistentAD.imageModel.height/imageWidth);
        height += 60;
    } else {
        height = prefferedCellPureTitleHeightWithHeight(height);
    }
    return height;
}

@end
