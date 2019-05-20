//
//  FHhomeHouseTypeBannerCell.m
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/4/30.
//

#import "FHhomeHouseTypeBannerCell.h"
#import <UIFont+House.h>
#import <UIColor+Theme.h>
#import "FHEnvContext.h"
#import "FHConfigModel.h"

@implementation FHhomeHouseTypeBannerCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)refreshData:(id)data
{
    FHConfigDataModel *dataModel = [[FHEnvContext sharedInstance] getConfigFromCache];
    
    if (!dataModel.opData2list || dataModel.opData2list.count == 0) {
        return;
    }
    
    if (![dataModel.opData2list.firstObject isKindOfClass:[FHConfigDataOpData2ListModel class]]) {
        return;
    }
    
    NSArray<FHConfigDataOpData2ItemsModel> *items = ((FHConfigDataOpData2ListModel *)dataModel.opData2list.firstObject).opDataList.items;
    CGFloat viewWidth = ([UIScreen mainScreen].bounds.size.width - 28) / 4.0f;
    
    for (NSInteger i = 0; i < items.count; i++) {
        FHConfigDataOpData2ItemsModel *itemModel = items[i];

        UIView *containView = [UIView new];
        [containView setFrame:CGRectMake( i * viewWidth + 14, 0.0f, viewWidth, 80)];
        switch (i) {
            case 0:
                [containView setBackgroundColor:[UIColor blueColor]];
                break;
            case 1:
                [containView setBackgroundColor:[UIColor greenColor]];
                break;
            case 2:
                [containView setBackgroundColor:[UIColor orangeColor]];
                break;
            case 3:
                [containView setBackgroundColor:[UIColor purpleColor]];
                break;
            default:
                break;
        }
        
        UILabel *titleLabel = [UILabel new];
        titleLabel.text = itemModel.title;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        [titleLabel setFrame:CGRectMake(0, 0, viewWidth, 20)];
        titleLabel.font = [UIFont themeFontMedium:14];
        [containView addSubview:titleLabel];
        [self.contentView addSubview:containView];
    }
    
}

@end
