//
//  FHUGCTagsView.m
//  FHHouseUGC
//
//  Created by wangzhizhou on 2020/2/26.
//

#import "FHUGCTagsView.h"
#import "UIFont+House.h"
#import "UIColor+Theme.h"
#import "BTDMacros.h"
#import "Masonry.h"

#define SELECT_TAGS_VIEW_CONTAINER_HEIGHT 44
#define SELECT_TAGS_LABEL_DEFAULT_TEXT @"丰富内容标签，上精选点评(可多选)"

#pragma mark - UI辅助类

@interface FHUGCTagsViewFlowLayout : UICollectionViewFlowLayout
@end
@implementation FHUGCTagsViewFlowLayout
-(instancetype)init {
    if(self = [super init]) {
        self.estimatedItemSize = CGSizeMake(80, 32);
        self.minimumLineSpacing = 10;
        self.minimumInteritemSpacing = 10;
        self.sectionInset = UIEdgeInsetsMake(9, 15, 9, 15);
    }
    return self;
}
- (NSArray *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSArray * layoutAttributes_t = [super layoutAttributesForElementsInRect:rect];
    NSArray * layoutAttributes = [[NSArray alloc]initWithArray:layoutAttributes_t copyItems:YES];
    //用来临时存放一行的Cell数组
    NSMutableArray * layoutAttributesTemp = [[NSMutableArray alloc]init];
    for (NSUInteger index = 0; index < layoutAttributes.count ; index++) {
        
        UICollectionViewLayoutAttributes *currentAttr = layoutAttributes[index]; // 当前cell的位置信息
        UICollectionViewLayoutAttributes *previousAttr = index == 0 ? nil : layoutAttributes[index-1]; // 上一个cell 的位置信
        UICollectionViewLayoutAttributes *nextAttr = index + 1 == layoutAttributes.count ?
        nil : layoutAttributes[index+1];//下一个cell 位置信息
        
        //加入临时数组
        [layoutAttributesTemp addObject:currentAttr];
        CGFloat previousY = previousAttr == nil ? 0 : CGRectGetMaxY(previousAttr.frame);
        CGFloat currentY = CGRectGetMaxY(currentAttr.frame);
        CGFloat nextY = nextAttr == nil ? 0 : CGRectGetMaxY(nextAttr.frame);
        //如果当前cell是单独一行
        if (currentY != previousY && currentY != nextY){
            if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionHeader]) {
                [layoutAttributesTemp removeAllObjects];
            }else if ([currentAttr.representedElementKind isEqualToString:UICollectionElementKindSectionFooter]){
                [layoutAttributesTemp removeAllObjects];
            }else{
                [self setCellFrameWith:layoutAttributesTemp];
            }
        }
        //如果下一个cell在本行，这开始调整Frame位置
        else if( currentY != nextY) {
            [self setCellFrameWith:layoutAttributesTemp];
        }
    }
    return layoutAttributes;
}

-(void)setCellFrameWith:(NSMutableArray*)layoutAttributes{
    CGFloat nowWidth = 0.0;
    nowWidth = self.sectionInset.left;
    for (UICollectionViewLayoutAttributes * attributes in layoutAttributes) {
        CGRect nowFrame = attributes.frame;
        nowFrame.origin.x = nowWidth;
        attributes.frame = nowFrame;
        nowWidth += nowFrame.size.width + self.minimumInteritemSpacing;
    }
    
    [layoutAttributes removeAllObjects];
}
@end


@interface FHUGCTagCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *titleLabel;

+ (NSString *)reuseIdentifier;
@end

@implementation FHUGCTagCell
+ (NSString *)reuseIdentifier {
    return NSStringFromClass(self.class);
}
-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.backgroundColor = [UIColor themeGray7];
        self.layer.cornerRadius = 16;
        self.layer.masksToBounds = YES;
        
        [self addSubview:self.titleLabel];
        [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(8);
            make.right.equalTo(self).offset(-8);
            make.top.equalTo(self).offset(5);
            make.bottom.equalTo(self).offset(-5);
        }];
        
    }
    return self;
}
- (void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        self.backgroundColor = [UIColor themeOrange2];
        self.titleLabel.textColor = [UIColor themeOrange1];
        
    } else {
        self.backgroundColor = [UIColor themeGray7];
        self.titleLabel.textColor = [UIColor themeGray1];
    }
}
- (UILabel *)titleLabel {
    if(!_titleLabel) {
        _titleLabel = [UILabel new];
        _titleLabel.font = [UIFont themeFontRegular:16];
        _titleLabel.textColor = [UIColor themeGray1];
    }
    return _titleLabel;
}
- (UICollectionViewLayoutAttributes *)preferredLayoutAttributesFittingAttributes:(UICollectionViewLayoutAttributes *)layoutAttributes {
    UICollectionViewLayoutAttributes *attributes = [super preferredLayoutAttributesFittingAttributes:layoutAttributes];
    CGRect rect = [self.titleLabel.text boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, self.frame.size.height) options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesFontLeading|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName: self.titleLabel.font} context:nil];
    rect.size.width += 16;
    rect.size.height += 10;
    attributes.frame = rect;
    return attributes;
}
@end

@interface FHUGCTagsView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) UIView *selectedViewContainer;

@property (nonatomic, strong) UIView *topSepLine;

@property (nonatomic, strong) UILabel *descLabel;

@property (nonatomic, strong) UILabel *selectedTagsLabel;

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, strong) NSArray<FHUGCTagModel*> *tagsInfo;

@end

#pragma mark - 主类

@implementation FHUGCTagsView

-(UIView *)selectedViewContainer {
    if(!_selectedViewContainer) {
        _selectedViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, SELECT_TAGS_VIEW_CONTAINER_HEIGHT)];
    
        [_selectedViewContainer addSubview:self.topSepLine];
        [_selectedViewContainer addSubview:self.descLabel];
        [_selectedViewContainer addSubview:self.selectedTagsLabel];
        
        [self setSelectedTagsLabelText:SELECT_TAGS_LABEL_DEFAULT_TEXT isDefaultStyle:YES];
        
        [self.topSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self.selectedViewContainer);
            make.height.mas_equalTo(1);
        }];
        
        [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topSepLine.mas_bottom);
            make.bottom.equalTo(self.selectedViewContainer);
            make.left.equalTo(self.selectedViewContainer).offset(20);
        }];
        
        [self.selectedTagsLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.topSepLine.mas_bottom);
            make.bottom.equalTo(self.selectedViewContainer);
            make.right.equalTo(self.selectedViewContainer).offset(-20);
            make.left.equalTo(self.descLabel.mas_right);
        }];
    }
    return _selectedViewContainer;
}

- (UIView *)topSepLine {
    if(!_topSepLine) {
        _topSepLine = [UIView new];
        _topSepLine.backgroundColor = [UIColor themeGray6];
    }
    return _topSepLine;
}

- (UILabel *)descLabel {
    if(!_descLabel) {
        _descLabel = [UILabel new];
        _descLabel.font = [UIFont themeFontRegular:16];
        _descLabel.textColor = [UIColor themeGray1];
        _descLabel.text = @"选择标签：";
    }
    return _descLabel;
}

- (UILabel *)selectedTagsLabel {
    if(!_selectedTagsLabel) {
        _selectedTagsLabel = [UILabel new];
        _selectedTagsLabel.font = [UIFont themeFontRegular:14];
    }
    return _selectedTagsLabel;
}

- (void)setSelectedTagsLabelText:(NSString *)text isDefaultStyle:(BOOL)isDefault {
    if(isDefault) {
        self.selectedTagsLabel.textColor = [UIColor themeGray3];
    } else {
        self.selectedTagsLabel.textColor = [UIColor themeGray1];
    }
    self.selectedTagsLabel.text = text;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        self.hidden = YES;
        
        [self addSubview:self.selectedViewContainer];
            
        [self addSubview:self.collectionView];
        
        [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.selectedViewContainer.mas_bottom);
            make.left.right.bottom.equalTo(self);
        }];
    }
    return self;
}

- (void)refreshWithTags:(NSArray<FHUGCTagModel*> *)tags {
    
    self.tagsInfo = tags;
    
    [self.collectionView reloadData];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        CGRect frame = self.frame;
        frame.size.height =  self.collectionView.contentSize.height + SELECT_TAGS_VIEW_CONTAINER_HEIGHT;
        self.frame = frame;
        self.hidden = NO;
    });
}

- (NSArray<FHUGCTagModel *> *)selectedTags {
    NSMutableArray<FHUGCTagModel*> *ret = [NSMutableArray array];
    @weakify(self);
    [self.collectionView.indexPathsForSelectedItems enumerateObjectsUsingBlock:^(NSIndexPath * _Nonnull indexPath, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        [ret addObject:[self.tagsInfo objectAtIndex:indexPath.row]];
    }];
    return ret;
}

#pragma mark - 懒加载成员

- (UICollectionView *)collectionView {
    if(!_collectionView) {
        
        FHUGCTagsViewFlowLayout *flowLayout = [FHUGCTagsViewFlowLayout new];
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor themeWhite];
        
        [_collectionView registerClass:FHUGCTagCell.class forCellWithReuseIdentifier: [FHUGCTagCell reuseIdentifier]];
        _collectionView.allowsMultipleSelection = YES;
        _collectionView.userInteractionEnabled = YES;
        
        
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
    }
    return _collectionView;
}

#pragma mark - UICollectionViewDelegate

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.tagsInfo.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FHUGCTagCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:[FHUGCTagCell reuseIdentifier] forIndexPath:indexPath];
    FHUGCTagModel *tagInfo = [self.tagsInfo objectAtIndex:indexPath.row
                              ];
    cell.titleLabel.text = tagInfo.name;
    return cell;
}

- (BOOL)collectionView:(UICollectionView *)collectionView shouldSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSArray<NSIndexPath *> *indexPathsForSelectedItems = collectionView.indexPathsForSelectedItems;

    if([indexPathsForSelectedItems containsObject:indexPath]) {
        [collectionView deselectItemAtIndexPath:indexPath animated:YES];
        return NO;
    }
    return YES;
}
@end