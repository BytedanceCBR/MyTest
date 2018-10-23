//
//  WDWendaMoreListHeaderView.h
//  Article
//
//  Created by wangqi.kaisa on 2017/5/10.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"

#define kWDWendaMoreListHeaderViewHeight 40

typedef void(^WDWendaMoreListHeaderViewClickedBlock)(void);

@interface WDWendaMoreListHeaderView : SSThemedView

- (void)setTitle:(NSString *)title clickedBlock:(WDWendaMoreListHeaderViewClickedBlock)block;

@end
