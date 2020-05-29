//
//  FHFloorPanDetailPropertyListCell.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/4/12.
//

#import "FHFloorPanDetailPropertyListCell.h"
#import "FHPropertyListCorrectingRowView.h"
#import "FHDetailBaseModel.h"
#import "FHHouseBaseInfoModel.h"
#import <TTBaseLib/TTBaseMacro.h>
#import "FHCommonDefines.h"
#import <FHHouseBase/UIImage+FIconFont.h>
#import "FHUIAdaptation.h"


#define kGrayLineX 19
@interface FHFloorPanDetailPropertyListCell ()

@property (nonatomic, weak) UIImageView *shadowImage;
@property (nonatomic, strong) NSMutableArray *itemArray;
@property (nonatomic, strong) UIView *grayLineView;


@end
@implementation FHFloorPanDetailPropertyListCell


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
        _itemArray = [[NSMutableArray alloc]init];
        [self setupUI];
    }
    return self;
}

- (void)refreshWithData:(id)data{
    if (self.currentData == data || ![data isKindOfClass:[FHFloorPanDetailPropertyListModel class]]) {
        return;
    }
    self.currentData = data;
    FHFloorPanDetailPropertyListModel *model = (FHFloorPanDetailPropertyListModel *)data;
    adjustImageScopeType(model)
    __block UIView *lastView = nil; // 最后一个视图
     NSInteger count = model.baseInfo.count;
     if (count > 0) {
         NSMutableArray *singles = [NSMutableArray new];
         __block NSInteger doubleCount = 0;// 两列计数
         __block CGFloat topOffset = kGrayLineX + 10;// 高度
         __block CGFloat listRowHeight = 29;// 30
         __block CGFloat lastViewLeftOffset = 20;
         __block CGFloat lastTopOffset = 20;
         CGFloat viewWidth = (UIScreen.mainScreen.bounds.size.width - 40) / 2;
         [model.baseInfo enumerateObjectsUsingBlock:^(FHHouseBaseInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
             if (obj.isSingle) {
                 [singles addObject:obj];
             } else {
                 // 两列
                 if (doubleCount % 2 == 0) {
                     // 第1列
                     FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                     [self.contentView addSubview:v];
                     [self.itemArray addObject:v];
                     [v mas_makeConstraints:^(MASConstraintMaker *make) {
                         make.top.mas_equalTo(topOffset);
                         make.left.mas_equalTo(31);
                         make.width.mas_equalTo(viewWidth);
                         make.height.mas_equalTo(listRowHeight);
                     }];
                     v.keyLabel.text = obj.attr;
                     v.valueLabel.text = obj.value;
                     v.keyLabel.font = [UIFont themeFontRegular:12];
                     v.valueLabel.font = [UIFont themeFontMedium:12];
                     v.keyLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
                     v.valueLabel.textColor = [UIColor themeGray2];
                     lastView = v;
                     lastViewLeftOffset = 20;
                     lastTopOffset = topOffset;
                 } else {
                     // 第2列
                     FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                     [self.contentView addSubview:v];
                     [self.itemArray addObject:v];
                     [v mas_makeConstraints:^(MASConstraintMaker *make) {
                         make.top.mas_equalTo(topOffset);
                         make.left.mas_equalTo(31 + viewWidth);
                         make.width.mas_equalTo(viewWidth);
                         make.height.mas_equalTo(listRowHeight);
                     }];
                     v.keyLabel.text = obj.attr;
                     v.valueLabel.text = obj.value;
                     v.keyLabel.font = [UIFont themeFontRegular:12];
                     v.valueLabel.font = [UIFont themeFontMedium:12];
                     v.keyLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
                     v.valueLabel.textColor = [UIColor themeGray2];
                     lastView = v;
                     lastViewLeftOffset = 20 + viewWidth;
                     lastTopOffset = topOffset;
                     //
                     topOffset += listRowHeight;
                 }
                 doubleCount += 1;
             }
         }];
         // 添加单列数据
         if (singles.count > 0) {
             // 重新计算topOffset
             topOffset = kGrayLineX + 10 + (doubleCount / 2 + doubleCount % 2) * listRowHeight;
             [singles enumerateObjectsUsingBlock:^(FHHouseCoreInfoModel*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                 FHPropertyListCorrectingRowView *v = [[FHPropertyListCorrectingRowView alloc] init];
                 [self.contentView addSubview:v];
                   [self.itemArray addObject:v];
                 
                 
                 v.keyLabel.text = obj.attr;
                 v.valueLabel.text = obj.value;
                 v.keyLabel.font = [UIFont themeFontRegular:12];
                 v.valueLabel.font = [UIFont themeFontMedium:12];
                 v.keyLabel.textColor = [UIColor colorWithHexStr:@"#aeadad"];
                 v.valueLabel.textColor = [UIColor themeGray2];
                 [v.valueLabel sizeToFit];
                 [v.keyLabel sizeToFit];
                 CGFloat keyWidth = [v.keyLabel sizeThatFits:CGSizeMake(SCREEN_WIDTH - 31 * 2, v.keyLabel.font.lineHeight)].width;
                 
                 [v.keyLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(0);
                     make.top.mas_equalTo(10);
                     make.width.mas_equalTo(keyWidth);
                     make.height.mas_equalTo(20);
                 }];
                 v.valueLabel.numberOfLines = 0;
                NSDictionary *attributes = @{NSFontAttributeName: [UIFont themeFontMedium:12]};
                CGRect rect = [obj.value boundingRectWithSize:CGSizeMake(SCREEN_WIDTH- 31*2 - 10 - keyWidth, CGFLOAT_MAX)
                                                           options:NSStringDrawingUsesLineFragmentOrigin
                                                        attributes:attributes
                                                           context:nil];
                 CGFloat valueHeight = rect.size.height;
                 [v.valueLabel mas_remakeConstraints:^(MASConstraintMaker *make) {
                     make.left.mas_equalTo(v.keyLabel.mas_right).offset(10);
                     make.top.mas_equalTo(10);
                     make.height.mas_equalTo(valueHeight);
                     make.right.mas_equalTo(0);
                     make.bottom.mas_equalTo(v);
                 }];
                 
                 [v mas_makeConstraints:^(MASConstraintMaker *make) {
                     make.top.mas_equalTo(topOffset);
                     make.left.mas_equalTo(31);
                     make.right.mas_equalTo(-31);
                     make.height.mas_equalTo(MAX(valueHeight + 10, listRowHeight));
                 }];
                 lastView = v;
                 lastViewLeftOffset = 20;
                 lastTopOffset = topOffset;
                 
                 topOffset += listRowHeight;
             }];
         }
     }
         [lastView mas_updateConstraints:^(MASConstraintMaker *make) {
             make.bottom.mas_equalTo(self.shadowImage.mas_bottom).offset(-50);
         }];
         [self layoutIfNeeded];
}

- (void)setupUI
{
    [self.contentView addSubview:self.shadowImage];
    self.grayLineView = [[UIView alloc]init];
   // self.grayLineView.backgroundColor = [UIColor colorWithHexStr:@"#e7e7e7"];
    self.grayLineView.layer.borderColor = [[UIColor colorWithHexStr:@"#e7e7e7"] CGColor];
    self.grayLineView.layer.borderWidth = 0.5;
    [self.contentView addSubview:self.grayLineView];
    
    [self.shadowImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView);
        make.right.mas_equalTo(self.contentView);
        make.top.equalTo(self.contentView).offset(-12);
        make.bottom.equalTo(self.contentView).offset(12);
    }];
    [self.grayLineView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(self.contentView).offset(34);
        make.right.mas_equalTo(self.contentView).offset(- 34);
        make.top.mas_equalTo(self.contentView).offset(kGrayLineX);
        make.height.mas_equalTo(0.5);
    }];
    
    
}
- (UIImageView *)shadowImage {
    if (!_shadowImage) {
        UIImageView *shadowImage = [[UIImageView alloc]init];
        [self.contentView addSubview:shadowImage];
        _shadowImage = shadowImage;
    }
    return  _shadowImage;
}
- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
@implementation FHFloorPanDetailPropertyListModel



@end
