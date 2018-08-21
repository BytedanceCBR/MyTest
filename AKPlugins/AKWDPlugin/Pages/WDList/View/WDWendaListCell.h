//
//  WDWendaListCell.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/11.
//
//

#import "SSThemed.h"
#import "WDListCellRouterCenter.h"

@interface WDWendaListCell : SSThemedTableViewCell<WDListCellBaseProtocol,WDListCellVideoProtocol>

@property (nonatomic, assign) CGRect videoCoverPicFrame;

@end
