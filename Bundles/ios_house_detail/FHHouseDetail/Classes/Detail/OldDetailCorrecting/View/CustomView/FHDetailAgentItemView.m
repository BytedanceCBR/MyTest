//
//  FHDetailAgentItemView.m
//  Pods
//
//  Created by bytedance on 2020/8/23.
//

#import "FHDetailAgentItemView.h"
#import <Masonry/Masonry.h>
#import <FHCommonUI/UIFont+House.h>
#import <FHCommonUI/UIColor+Theme.h>
#import <FHCommonUI/UILabel+House.h>
#import <BDWebImage/BDWebImage.h>
#import "FHExtendHotAreaButton.h"

@interface FHDetailAgentItemTagsViewCell: UICollectionViewCell

@property (nonatomic, strong) UILabel *tagLabel;
@property (nonatomic, strong) UIImageView *tagImageView;

+ (NSString *)reuseIdentifier;

@end

@implementation FHDetailAgentItemTagsViewCell

+ (NSString *)reuseIdentifier {
    return NSStringFromClass([self class]);
}

-(UILabel *)tagLabel {
    if(!_tagLabel) {
        _tagLabel = [[UILabel alloc] init];
        _tagLabel.font = [UIFont themeFontMedium:10];
        _tagLabel.numberOfLines = 1;
        _tagLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _tagLabel;
}

-(instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.tagLabel];
        [self.tagLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(self.contentView);
        }];
        self.contentView.layer.cornerRadius = 2;
//        self.contentView.layer.masksToBounds = YES;
    }
    return self;
}

- (void)refreshWithData:(id)data {
    FHRealtorTag *model = data;
    self.tagLabel.text = model.text;
    self.contentView.backgroundColor = [UIColor colorWithHexStr:model.backgroundColor];
    self.contentView.layer.borderColor = [UIColor colorWithHexStr:model.borderColor].CGColor;
    self.contentView.layer.borderWidth = .3;
    self.tagLabel.textColor = [UIColor colorWithHexStr:model.fontColor];
    if (model.prefixIconUrl.length > 0) {
        if (!_tagImageView) {
            _tagImageView = [[UIImageView alloc] init];
            [_tagImageView bd_setImageWithURL:[NSURL URLWithString:model.prefixIconUrl]];
            [self.contentView addSubview:self.tagImageView];
            [self.tagImageView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.left.top.mas_equalTo(2);
                make.width.height.mas_equalTo(14);
            }];
        }
        [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.tagImageView.mas_right);
            make.centerY.mas_equalTo(self);
        }];
    } else {
        if (self.tagImageView) {
            [self.tagImageView removeFromSuperview];
            self.tagImageView = nil;
        }
        [self.tagLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
    }
}


@end

@interface FHDetailAgentItemTagsFlowLayout : UICollectionViewFlowLayout

@property (nonatomic, assign) CGFloat maximumInteritemSpacing;

@end

@implementation FHDetailAgentItemTagsFlowLayout

- (NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect
{
    //使用系统帮我们计算好的结果。
    NSArray *attributes = [super layoutAttributesForElementsInRect:rect];
    
    //第0个cell没有上一个cell，所以从1开始
    for(int i = 1; i < [attributes count]; ++i) {
        //这里 UICollectionViewLayoutAttributes 的排列总是按照 indexPath的顺序来的。
        UICollectionViewLayoutAttributes *curAttr = attributes[i];
        UICollectionViewLayoutAttributes *preAttr = attributes[i-1];
        
        NSInteger origin = CGRectGetMaxX(preAttr.frame);
        //根据  maximumInteritemSpacing 计算出的新的 x 位置
        CGFloat targetX = origin + self.maximumInteritemSpacing;
        // 只有系统计算的间距大于  maximumInteritemSpacing 时才进行调整
        if (CGRectGetMinX(curAttr.frame) > targetX) {
            // 换行时不用调整
            if (targetX + CGRectGetWidth(curAttr.frame) <= self.collectionViewContentSize.width) {
                CGRect frame = curAttr.frame;
                frame.origin.x = targetX;
                curAttr.frame = frame;
            } else {
                CGRect frame = curAttr.frame;
                frame.size.width = 0;
                curAttr.frame = frame;
            }
        }
    }
    return attributes;
}

-(instancetype)init {
    if(self = [super init]) {
        self.maximumInteritemSpacing = 6.0f;
        self.minimumInteritemSpacing = 6.0f;
        self.scrollDirection = UICollectionViewScrollDirectionVertical;
    }
    return self;
}
@end

@interface FHDetailAgentItemView()<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, assign) CGFloat topMargin;
@property (nonatomic, strong) FHDetailContactModel *model;
@property (nonatomic, strong) UICollectionView *tagsView;
@property (nonatomic, strong) UIView *vSepLine;

@end

@implementation FHDetailAgentItemView

-(UILabel *)realtorEvaluate {
    if(!_realtorEvaluate) {
        _realtorEvaluate = [UILabel new];
        _realtorEvaluate.textColor = [UIColor themeGray3];
        _realtorEvaluate.font = [UIFont themeFontRegular:12];
    }
    return _realtorEvaluate;
}

- (UICollectionView *)tagsView {
    if(!_tagsView) {
        _tagsView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:[[FHDetailAgentItemTagsFlowLayout alloc] init]];
        _tagsView.scrollEnabled = NO;
        _tagsView.backgroundColor = [UIColor whiteColor];
        _tagsView.delegate = self;
        _tagsView.dataSource = self;

        [_tagsView registerClass:[FHDetailAgentItemTagsViewCell class] forCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier]];
    }
    return _tagsView;
}

- (UIView *)vSepLine {
    if(!_vSepLine) {
        _vSepLine = [UIView new];
        _vSepLine.backgroundColor = [UIColor themeGray6];
    }
    return _vSepLine;
}

- (UIImageView *)agencyBac{
    if (!_agencyBac) {
        _agencyBac = [[UIImageView alloc]init];
        _agencyBac.image = [UIImage imageNamed:@"realtor_name_bac"];
        _agencyBac.layer.borderWidth = 0.5;
        _agencyBac.layer.borderColor = [[UIColor colorWithHexString:@"#d6d6d6"] CGColor];
        _agencyBac.layer.cornerRadius = 2.0;
        _agencyBac.layer.masksToBounds = YES;
        
    }
    return _agencyBac;
}

- (UIView *)agencyDescriptionBac{
    if (!_agencyDescriptionBac) {
        _agencyDescriptionBac = [[UIView alloc]init];
        _agencyDescriptionBac.backgroundColor = [UIColor colorWithHexString:@"#fefaf4"];
        _agencyDescriptionBac.layer.cornerRadius = 2.0;
        _agencyDescriptionBac.layer.masksToBounds = YES;
    }
    return _agencyDescriptionBac;
}

- (UILabel *)agencyDescriptionLabel{
    if (!_agencyDescriptionLabel) {
        _agencyDescriptionLabel = [[UILabel alloc] init];
        _agencyDescriptionLabel.font = [UIFont themeFontRegular:10];
        _agencyDescriptionLabel.backgroundColor = [UIColor clearColor];
        _agencyDescriptionLabel.textColor = [UIColor themeBlack];
        _agencyDescriptionLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _agencyDescriptionLabel;
}


-(instancetype)initWithModel:(FHDetailContactModel *)model topMargin:(CGFloat )topMargin{
    if (self = [super init]) {
        self.topMargin = topMargin;
        self.model = model;
        switch (self.model.realtorCellShow) {
            case FHRealtorCellShowStyle1: // 经纪人名字和公司名字左右排列的样式: 标签
                [self layoutForStyle1];
                break;
            case FHRealtorCellShowStyle2: // 经纪人名字和公司名字左右排列的样式: 话术
                [self layoutForStyle2];
                break;
            case FHRealtorCellShowStyle3: // 经纪人名字和公司名字左右排列的样式: 公司介绍且公司名字后面有灰色背景
                [self layoutForStyle3];
                break;
            case FHRealtorCellShowStyle0: // 经纪人名字和公司名字上下排列的样式
            default:
                [self layoutForStyle0];
                break;
        }
    }
    return self;
}

- (void)layoutForStyle0 {
    [self setupUI];
    if (self.model.realtorScoreDisplay.length <= 0 || self.model.realtorScoreDescription.length <=0) {
           self.score.hidden = YES;
           self.scoreDescription.hidden = YES;
       }
}

- (void)layoutForStyle1 {
    [self setupUI];
    [self modifiedLayoutNameNeedShowCenter:self.model.realtorTags.count >0||(self.model.realtorScoreDisplay.length>0&&self.model.realtorScoreDescription.length>0)];
    [self addSubview:self.tagsView];
    if (self.model.realtorScoreDisplay.length>0 && self.model.realtorScoreDescription.length>0) {
         [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
               make.height.mas_equalTo(18);
               make.left.equalTo(self.name);
               make.right.equalTo(self.callBtn.mas_right);
             make.top.equalTo(self.score.mas_bottom).offset(self.model.realtorTags.count>0?6:8);
           }];
    }else {
        self.score.hidden = YES;
        self.scoreDescription.hidden = YES;
        [self.tagsView mas_makeConstraints:^(MASConstraintMaker *make) {
              make.height.mas_equalTo(18);
              make.left.equalTo(self.name);
              make.right.equalTo(self.callBtn.mas_right);
              make.top.equalTo(self.name.mas_bottom).offset(8);
          }];
    }
}

- (void)layoutForStyle2 {
    [self setupUI];
    [self modifiedLayoutNameNeedShowCenter:self.model.realtorEvaluate.length>0||(self.model.realtorScoreDisplay.length>0&&self.model.realtorScoreDescription.length>0)];
    [self addSubview:self.realtorEvaluate];
    if (self.model.realtorScoreDisplay.length>0 && self.model.realtorScoreDescription.length>0) {
         [self.realtorEvaluate mas_makeConstraints:^(MASConstraintMaker *make) {
             make.height.mas_equalTo(17);
             make.left.equalTo(self.name);
             make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
             make.top.equalTo(self.score.mas_bottom).offset(self.model.realtorTags.count>0?6:8);
         }];
    }else {
        self.score.hidden = YES;
        self.scoreDescription.hidden = YES;
        [self.realtorEvaluate mas_makeConstraints:^(MASConstraintMaker *make) {
              make.height.mas_equalTo(17);
              make.left.equalTo(self.name);
              make.right.equalTo(self.imBtn.mas_left).offset(-10);
              make.top.equalTo(self.name.mas_bottom).offset(8);
          }];
    }

}

- (void)layoutForStyle3 {
    [self setupUI];//realtor_name_bac
    //
    self.score.hidden = YES;
    self.scoreDescription.hidden = YES;
    [self addSubview:self.agencyBac];
    [self.agency mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.agencyBac).offset(3);
        make.bottom.mas_equalTo(self.agencyBac).offset(-3);
        make.left.mas_equalTo(self.agencyBac).offset(5);
        make.right.mas_equalTo(self.agencyBac).offset(-5);
    }];
    
    [self bringSubviewToFront:self.agency];
    self.name.font = [UIFont themeFontMedium:16];
    self.name.textColor = [UIColor themeBlack];
    
    self.agency.textColor = [UIColor colorWithHexString:@"#929292"];
    self.agency.font = [UIFont themeFontMedium:10];
    [self newHouseModifiedLayoutNameNeedShowCenter:self.model.agencyDescription.length <= 0];
    if (self.model.agencyDescription.length > 0) {
        [self addSubview:self.agencyDescriptionBac];
        [self addSubview:self.agencyDescriptionLabel];
        self.agencyDescriptionLabel.text = self.model.agencyDescription;
        [self.agencyDescriptionLabel sizeToFit];
        
        [self.agencyDescriptionLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(self.agencyDescriptionBac).offset(3);
            make.bottom.mas_equalTo(self.agencyDescriptionBac).offset(-3);
            make.left.mas_equalTo(self.agencyDescriptionBac).offset(10);
            make.right.mas_equalTo(self.agencyDescriptionBac).offset(-10);
        }];
        [self.agencyDescriptionLabel setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
        
        [self.agencyDescriptionBac mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.mas_equalTo(self.avatorView.mas_right).offset(8);
            make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left);
            make.height.mas_equalTo(18);
            make.bottom.mas_equalTo(self.avatorView);
        }];
    }
    
    [self.callBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(26);
        make.right.mas_equalTo(-15);
        make.top.mas_equalTo(self.name);
    }];
    [self.imBtn mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(26);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-38);
        make.top.mas_equalTo(self.name);
    }];
    
}

-(void)newHouseModifiedLayoutNameNeedShowCenter:(BOOL )showCenter{

    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatorView.mas_right).offset(10);
        if (showCenter) {
            make.centerY.mas_equalTo(self.avatorView);
        } else {
            make.top.mas_equalTo(self.avatorView.mas_top).mas_offset(4);
        }
        make.height.mas_equalTo(20);
    }];
    
    [self.name setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];  //这个好神奇！！！
    
    [self.agencyBac mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.name);
        make.height.mas_equalTo(16);
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];
    
    //[self.agency setContentCompressionResistancePriority:UILayoutPriorityDragThatCannotResizeScene forAxis:UILayoutConstraintAxisHorizontal];
    self.agency.textAlignment = NSTextAlignmentCenter;
    
}

-(void)modifiedLayoutNameNeedShowCenter:(BOOL )showCenter{
    
    [self addSubview: self.vSepLine];
    
    [self.vSepLine mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.mas_equalTo(1);
        make.height.mas_equalTo(14);
        make.centerY.equalTo(self.name);
        make.left.equalTo(self.name.mas_right).offset(6);
    }];
    [self.name mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatorView.mas_right).offset(10);
        if(!showCenter){
            make.centerY.equalTo(self.avatorView);
        }else {
            make.top.mas_equalTo(self.avatorView.mas_top).mas_offset(4);
        }
        make.height.mas_equalTo(20);
    }];
    [self.name setContentHuggingPriority:UILayoutPriorityDefaultHigh forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.agency mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.name);
        make.height.mas_equalTo(20);
        make.left.equalTo(self.vSepLine.mas_right).offset(6);
        make.right.equalTo(self.licenceIcon.mas_left).offset(-5);
    }];
    
    [self.agency setContentCompressionResistancePriority:UILayoutPriorityDefaultLow forAxis:UILayoutConstraintAxisHorizontal];
    
    [self.licenceIcon mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.agency.mas_right).offset(5);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];
}

-(void)configForLicenceIconWithHidden:(BOOL)isHidden {
    
    self.licenceIcon.hidden = isHidden;
    
    switch (self.model.realtorCellShow) {
        case FHRealtorCellShowStyle1:
        case FHRealtorCellShowStyle2:
        {
            [self.agency mas_updateConstraints:^(MASConstraintMaker *make) {
                if(self.licenceIcon.hidden){
                    make.right.equalTo(self.imBtn.mas_left).offset(-10);
                } else {
                    make.right.equalTo(self.licenceIcon.mas_left).offset(-5);
                }
            }];
        }
            break;
        case FHRealtorCellShowStyle0:
        default:
            NSLog(@"Do nothing!");
            break;
    }
}

- (void)setupUI {
    self.avatorView = [[FHRealtorAvatarView alloc] init];
    [self addSubview:self.avatorView];
    [self.avatorView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.width.mas_equalTo(50);
        make.left.mas_equalTo(16);
        make.top.mas_equalTo(self.topMargin);
    }];
    
    self.name = [UILabel createLabel:@"" textColor:@"" fontSize:18];
    self.name.textColor = [UIColor themeGray1];
    self.name.font = [UIFont themeFontMedium:18];
    self.name.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.name];
    [self.name mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.avatorView.mas_right).offset(14);
        make.top.mas_equalTo(self.avatorView.mas_top).mas_offset(4);
        make.height.mas_equalTo(22);
    }];
    
    self.callBtn = [[FHExtendHotAreaButton alloc] init];
    [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_call_normal_new"] forState:UIControlStateNormal];
    [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateSelected];
    [self.callBtn setImage:[UIImage imageNamed:@"detail_agent_call_press_new"] forState:UIControlStateHighlighted];
    [self addSubview:self.callBtn];
    [self.callBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(self.avatorView.mas_top);
    }];
    
    self.imBtn = [[FHExtendHotAreaButton alloc] init];
    [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_message_normal_new"] forState:UIControlStateNormal];
    [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateSelected];
    [self.imBtn setImage:[UIImage imageNamed:@"detail_agent_message_press_new"] forState:UIControlStateHighlighted];
    [self addSubview:self.imBtn];
    [self.imBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.height.mas_equalTo(36);
        make.right.mas_equalTo(self.callBtn.mas_left).offset(-20);
        make.top.mas_equalTo(self.callBtn.mas_top);
    }];

    self.licenceIcon = [[FHExtendHotAreaButton alloc] init];
    [self.licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateNormal];
    [self.licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateSelected];
    [self.licenceIcon setImage:[UIImage imageNamed:@"detail_contact"] forState:UIControlStateHighlighted];
    [self addSubview:self.licenceIcon];
    [self.licenceIcon mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.name.mas_right).offset(4);
        make.width.height.mas_equalTo(20);
        make.centerY.mas_equalTo(self.name);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left).offset(-10);
    }];
    
    self.agency = [UILabel createLabel:@"" textColor:@"" fontSize:16];
    self.agency.textColor = [UIColor themeGray3];
    self.agency.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.agency];
    [self.agency mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(self.name.mas_bottom);
        make.height.mas_equalTo(20);
        make.left.mas_equalTo(self.avatorView.mas_right).offset(14);
        make.right.mas_lessThanOrEqualTo(self.imBtn.mas_left);
    }];
    
    self.score = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    self.score.textColor = [UIColor themeGray1];
    self.score.font = [UIFont themeFontMedium:14];
    self.score.textAlignment = NSTextAlignmentLeft;
    [self.score setContentCompressionResistancePriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self.score setContentHuggingPriority:UILayoutPriorityRequired forAxis:UILayoutConstraintAxisHorizontal];
    [self addSubview:self.score];
    [self.score mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.name);
        make.top.equalTo(self.name.mas_bottom).offset(6);
    }];
    
    self.scoreDescription = [UILabel createLabel:@"" textColor:@"" fontSize:14];
    self.scoreDescription.textColor = [UIColor themeGray1];
    self.scoreDescription.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.scoreDescription];
    [self.scoreDescription mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.score.mas_right).offset(2);
        make.right.mas_lessThanOrEqualTo(self).offset(-20);
        make.centerY.equalTo(self.score);
    }];
}

#pragma mark - UICollectionViewDelegateFlowLayout

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    FHRealtorTag *tagInfo = [self.model.realtorTags objectAtIndex:indexPath.row];
    UIColor *fontColor = [UIColor colorWithHexStr:tagInfo.fontColor];
    UIColor *backgroundColor = [UIColor colorWithHexStr:tagInfo.backgroundColor];
    if(fontColor && backgroundColor) {
        CGSize itemSize = [tagInfo.text sizeWithAttributes:@{
                                                  NSForegroundColorAttributeName: fontColor,
                                                  NSBackgroundColorAttributeName: backgroundColor,
                                                  NSFontAttributeName: [UIFont themeFontRegular:10]
                                                  }];
        
        itemSize.width += 10;
        itemSize.height += 4;
        if (tagInfo.prefixIconUrl.length > 0) {
            itemSize.width += 11;
        }
        return itemSize;
    }
    return CGSizeZero;
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.model.realtorTags.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    FHDetailAgentItemTagsViewCell *tagCell = [collectionView dequeueReusableCellWithReuseIdentifier:[FHDetailAgentItemTagsViewCell reuseIdentifier] forIndexPath:indexPath];
    
    FHRealtorTag *tagInfo = [self.model.realtorTags objectAtIndex:indexPath.row];
    [tagCell refreshWithData:tagInfo];
    return tagCell;
}
@end
