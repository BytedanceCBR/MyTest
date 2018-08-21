//
//  WDWendaListLightLargeVideoCell.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import "SSThemed.h"
#import "WDListCellRouterCenter.h"

/*
 * 1.3 列表页轻回答（文字+）视频大图cell
 */

@interface WDWendaListLightLargeVideoCell : SSThemedTableViewCell<WDListCellBaseProtocol,WDListCellVideoProtocol>

@property (nonatomic, assign) CGRect videoCoverPicFrame;

@end
