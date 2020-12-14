//
//  FHNeighborhoodDetailCommentTagsCell.m
//  FHHouseDetail
//
//  Created by 谢思铭 on 2020/10/14.
//

#import "FHNeighborhoodDetailCommentTagsCell.h"

#define maxRowCount 3

@interface FHNeighborhoodDetailCommentTagsCell ()

@property(nonatomic , strong) NSMutableArray *tagViews;
@property(nonatomic , assign) CGFloat maxWidth;
@property(nonatomic , assign) CGFloat currentWidth;
@property(nonatomic , assign) CGFloat row;
@property(nonatomic , assign) CGFloat topMargin;
@property(nonatomic , assign) CGFloat leftMargin;

@end

@implementation FHNeighborhoodDetailCommentTagsCell

+ (CGSize)cellSizeWithData:(id)data width:(CGFloat)width {
    if (data && [data isKindOfClass:[FHNeighborhoodDetailCommentTagsModel class]]) {
        FHNeighborhoodDetailCommentTagsModel *model = (FHNeighborhoodDetailCommentTagsModel *)data;
        
        CGFloat height = 26;
        CGFloat maxWidth = width - 24;
        CGFloat row = 0;
        CGFloat currentWidth = 0;
        
        for (NSInteger i = 0; i < model.tags.count; i++) {
            FHNeighborhoodDetailCommentTagModel *tag = model.tags[i];
            CGFloat tagWidth = [FHNeighborhoodDetailCommentTagView getTagViewWidth:tag];
            if(currentWidth > 0){
                currentWidth += 6;
            }
            currentWidth += tagWidth;
            if(currentWidth > maxWidth){
                row++;
                currentWidth = tagWidth;
            }
        }
        
        if(row > (maxRowCount - 1)){
            row = maxRowCount - 1;
        }
        
        height += (row * 34);
        
        return CGSizeMake(width, height);
    }
    return CGSizeZero;
}

- (void)refreshWithData:(id)data {
    if (self.currentData == data || ![data isKindOfClass:[FHNeighborhoodDetailCommentTagsModel class]]) {
        return;
    }
    self.currentData = data;
    FHNeighborhoodDetailCommentTagsModel *model = (FHNeighborhoodDetailCommentTagsModel *)data;
    if (model) {
        [self removeAllTagViews];
        for (FHNeighborhoodDetailCommentTagModel *tag in model.tags) {
            [self addTagView:tag];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _tagViews = [NSMutableArray array];
        _maxWidth = [UIScreen mainScreen].bounds.size.width - 30 - 24;
        _currentWidth = 0;
        _row = 0;
        _topMargin = 0;
        _leftMargin = 12;
    }
    return self;
}

- (void)addTagView:(FHNeighborhoodDetailCommentTagModel *)tag {
    CGFloat tagWidth = [FHNeighborhoodDetailCommentTagView getTagViewWidth:tag];
    FHNeighborhoodDetailCommentTagView *tagView = [[FHNeighborhoodDetailCommentTagView alloc] initWithFrame:CGRectZero model:tag];
    tagView.layer.masksToBounds = YES;
    tagView.layer.cornerRadius = 13;
    [self.contentView addSubview:tagView];
    [self.tagViews addObject:tagView];
    
    if(self.currentWidth > 0){
        self.currentWidth += 6;
    }
    self.currentWidth += tagWidth;
    if(self.currentWidth > self.maxWidth){
        self.row++;
        self.currentWidth = tagWidth;
        self.leftMargin = 12;
    }else{
        self.leftMargin = 12 + (self.currentWidth - tagWidth);
    }
    
    if(self.row < maxRowCount){
        self.topMargin = 34 * self.row;
        [tagView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.contentView).offset(self.topMargin);
            make.left.mas_equalTo(self.contentView).offset(self.leftMargin);
            make.width.mas_equalTo(tagWidth);
            make.height.mas_equalTo(26);
        }];
    }else{
        tagView.hidden = YES;
    }
}

- (void)removeAllTagViews {
    for (NSInteger i = 0; i < self.tagViews.count; i++) {
        FHNeighborhoodDetailCommentTagView *tagView = self.tagViews[i];
        [tagView removeFromSuperview];
    }
    [self.tagViews removeAllObjects];
    _currentWidth = 0;
    _row = 0;
    _topMargin = 0;
    _leftMargin = 12;
}

@end

@implementation FHNeighborhoodDetailCommentTagsModel

@end
