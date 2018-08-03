//
//  TTHTSTabHeaderView.h
//  Article
//
//  Created by 王双华 on 2017/4/13.
//
//

#import "SSThemed.h"
#import "TTHeaderScrollView.h"

#define kTTHTSHeaderViewHeight      60

@interface TTHTSTabHeaderView : SSThemedView<TTHeaderViewProtocol>

@property (nonatomic, assign) CGFloat minimumHeaderHeight;

@property (nonatomic, assign) BOOL isDisplayView;

- (void)refreshUI;

@end
