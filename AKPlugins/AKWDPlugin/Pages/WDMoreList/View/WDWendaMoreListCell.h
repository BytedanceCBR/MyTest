//
//  WDWendaMoreListCell.h
//  Pods
//
//  Created by wangqi.kaisa on 2017/8/21.
//
//

#import "SSThemed.h"
#import "WDListCellRouterCenter.h"

/*
 * 8.21 折叠列表页的回答cell：图片和视频即使有也不显示
 *      和列表页分开，方便维护与拓展
 * 9.6  使用新的传值方式将埋点收敛到大VM中，避免cell引用大VM
 */

@interface WDWendaMoreListCell : SSThemedTableViewCell<WDListCellBaseProtocol>

@end
