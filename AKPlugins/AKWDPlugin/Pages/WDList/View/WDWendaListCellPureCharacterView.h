//
//  WDWendaListCellPureCharacterView.h
//  TTWenda
//
//  Created by wangqi.kaisa on 2018/1/3.
//

#import "SSThemed.h"

/*
 * 1.3 列表页cell中回答文字view，单独封装成一个view，方便复用
 * 1.4 默认行数n=8，最大行数m=12。不超过最大行数，显示默认行数（最后+...全文），否则全部显示。
 *     由服务端下发：defaultlines & maxlines
 * 1.7 文字大小，行高，段落间距暂时还不支持外界赋值
 */

@interface WDWendaListCellPureCharacterView : SSThemedView

@property (nonatomic, assign) BOOL isLightAnswer;

- (void)updateAbstContentLabelText:(NSString *)text numberOfLines:(NSInteger)numberOfLines;

- (void)refreshAbstContentLabelLayout:(CGFloat)height;

- (void)setHighlighted:(BOOL)highlighted;

@end
