//
//  WDWendaFirstWritterPopupView.h
//  Article
//
//  Created by 延晋 张 on 16/4/21.
//
//

#import "SSThemed.h"

@protocol WDWendaFirstWritterPopupViewDelegate <NSObject>

@optional

- (void)popUpViewWillDimissed;
- (void)popUpViewDidDimissed;

@end

@interface WDWendaFirstWritterPopupView : SSThemedView

@property (nonatomic, weak) id<WDWendaFirstWritterPopupViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame hintArray:(NSArray<NSString *> *)hintArray;

- (void)show;

@end
