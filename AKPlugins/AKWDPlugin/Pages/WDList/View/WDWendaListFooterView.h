//
//  WDWendaListFooterView.h
//  Article
//
//  Created by ZhangLeonardo on 15/12/14.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "WDListViewModel.h"

#define kWDWendaListFooterViewHeight 55
#define kWDWendaListNoAnswerFooterViewHeight 200

/*
 * 9.18 也需要接受AB开关控制
 */

typedef void(^WDWendaListFooterViewClickedBlock)(void);

@interface WDWendaListFooterView : SSThemedView

@property(nonatomic, strong) WDListViewModel *viewModel;

- (void)setTitle:(NSString *)title isShowArrow:(BOOL)isShowArrow isNoAnswers:(BOOL)isNoAnswers clickedBlock:(WDWendaListFooterViewClickedBlock)block;

- (void)setTitle:(NSString *)title isShowArrow:(BOOL)isShowArrow isNoAnswers:(BOOL)isNoAnswers isNew:(BOOL)isNew clickedBlock:(WDWendaListFooterViewClickedBlock)block;

@end
