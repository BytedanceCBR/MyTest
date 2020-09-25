//
//  FHNewHouseDetailDisclaimerSM.m
//  FHHouseDetail
//
//  Created by luowentao on 2020/9/9.
//

#import "FHNewHouseDetailDisclaimerSM.h"

@implementation FHNewHouseDetailDisclaimerSM

- (void)updateDetailModel:(FHDetailNewModel *)model {
    FHNewHouseDetailDisclaimerModel *disclaimerModel = [[FHNewHouseDetailDisclaimerModel alloc] init];
    disclaimerModel.disclaimer = [[FHDisclaimerModel alloc] init];
    disclaimerModel.disclaimer.text =  model.data.disclaimer.text;
    disclaimerModel.disclaimer.richText = model.data.disclaimer.richText;
    
    if (!model.data.highlightedRealtor) {
        // 当且仅当没有合作经纪人时，才在disclaimer中显示 经纪人 信息
        disclaimerModel.contact = model.data.contact;
    } else {
        disclaimerModel.contact = nil;
    }
    self.disclaimerModel = disclaimerModel;
}

@end
