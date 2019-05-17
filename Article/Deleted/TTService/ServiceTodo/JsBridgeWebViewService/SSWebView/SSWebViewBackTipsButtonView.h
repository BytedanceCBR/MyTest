//
//  SSWebViewBackTipsButtonView.h
//  Article
//
//  Created by chenren on 09/06/2017.
//
//

#import "SSWebViewBackButtonView.h"

@interface SSWebViewBackTipsButtonView : SSWebViewBackButtonView

@property(nonatomic, strong) UILabel *tipLabel;

- (void)setTipsCount:(NSInteger)count;

- (NSInteger)getBadgeNumber;

@end
