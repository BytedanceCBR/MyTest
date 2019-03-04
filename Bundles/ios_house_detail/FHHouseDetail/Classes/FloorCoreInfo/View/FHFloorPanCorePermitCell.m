//
//  FHFloorPanCorePermitCell.m
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2019/2/19.
//

#import "FHFloorPanCorePermitCell.h"

@interface FHFloorPanCorePermitCell ()

@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *listView;

@end

@implementation FHFloorPanCorePermitCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style
                reuseIdentifier:reuseIdentifier];
    if (self) {
       _headerView = [UIView new];
       [self.contentView addSubview:_headerView];
        [_headerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.contentView).offset(5);
            make.left.right.equalTo(self.contentView);
        }];
        
       NSArray *nameArray = @[@"预售许可证",@"发证信息",@"绑定信息"];
        
       for (NSInteger i = 0; i < [nameArray count]; i++) {
            NSString *stringName = nameArray[i];
            UILabel *labelName = [UILabel new];
            labelName.font = [UIFont themeFontRegular:15];
            labelName.textColor = [UIColor themeGray2];
            labelName.textAlignment = NSTextAlignmentCenter;
            labelName.text = stringName;
            [_headerView addSubview:labelName];
           
           [labelName mas_makeConstraints:^(MASConstraintMaker *make) {
               make.centerY.equalTo(labelName);
               make.left.mas_equalTo([UIScreen mainScreen].bounds.size.width / 3 * i);
               make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width / 3);
               make.height.mas_equalTo(30);
           }];
        }
        
        _listView = [UIView new];
        [self.contentView addSubview:_listView];
        [_listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.headerView.mas_bottom);
            make.left.right.equalTo(self.contentView);
            make.bottom.equalTo(self.contentView).offset(-10);
        }];
    }
    return self;
}

- (void)refreshWithData:(id)data
{
    if([data isKindOfClass:[FHFloorPanCorePermitCellModel class]])
    {
        
        NSArray<FHDetailNewCoreDetailDataPermitListModel *>*nameArray = ((FHFloorPanCorePermitCellModel *)data).permitList;
        
        for (NSInteger i = 0; i < 3; i++) {
            FHDetailNewCoreDetailDataPermitListModel *modelItem = (FHDetailNewCoreDetailDataPermitListModel *)nameArray.firstObject;
            if ([modelItem isKindOfClass:[FHDetailNewCoreDetailDataPermitListModel class]]) {
                UILabel *labelName = [UILabel new];
                labelName.font = [UIFont themeFontRegular:15];
                labelName.textColor = [UIColor themeGray1];
                labelName.numberOfLines = 0;
                labelName.textAlignment = NSTextAlignmentCenter;
                switch (i) {
                    case 0:
                        labelName.text = modelItem.permit ? modelItem.permit : @"-";
                        break;
                    case 1:
                        labelName.text = modelItem.permitDate ? modelItem.permitDate : @"-";
                        break;
                    case 2:
                        labelName.text = modelItem.bindBuilding ? modelItem.bindBuilding : @"-";
                        break;
                    default:
                        break;
                }
                [_listView addSubview:labelName];
                
                [labelName mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.bottom.top.equalTo(self.listView);
                    make.left.mas_equalTo([UIScreen mainScreen].bounds.size.width / 3 * i);
                    make.width.mas_equalTo([UIScreen mainScreen].bounds.size.width / 3);
                }];
            }
        }
    }
    
    [_listView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.headerView.mas_bottom).offset(30);
        make.left.right.equalTo(self.contentView);
        make.bottom.equalTo(self.contentView).offset(-10);
    }];
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

@implementation FHFloorPanCorePermitCellModel


@end
