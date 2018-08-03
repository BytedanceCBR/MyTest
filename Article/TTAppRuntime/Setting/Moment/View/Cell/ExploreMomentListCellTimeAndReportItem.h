//
//  ExploreMomentListCellTimeAndReportItem.h
//  Article
//
//  Created by 冯靖君 on 16/7/13.
//
//

#import "ExploreMomentListCellItemBase.h"
#import "SSThemed.h"

typedef void(^ReportActionBlock)();

@interface ExploreMomentListCellTimeAndReportItem : ExploreMomentListCellItemBase

@property(nonatomic, strong)UILabel * timeLabel;
@property(nonatomic, strong)SSThemedButton * reportButton;
@property(nonatomic, copy) ReportActionBlock trigReportActionBlock;

@end
