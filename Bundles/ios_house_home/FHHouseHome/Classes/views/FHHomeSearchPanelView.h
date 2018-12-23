//
//  FHHomeSearchPanelView.h
//  AFgzipRequestSerializer
//
//  Created by 谢飞 on 2018/12/21.
//

#import <UIKit/UIKit.h>
#import "Masonry.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeSearchPanelView : UIView
{
    
}

@property(nonatomic, strong) UIButton * changeCountryBtn;
@property(nonatomic, strong) UIButton * searchBtn;
@property(nonatomic, strong) UILabel * countryLabel;
@property(nonatomic, strong) NSMutableArray <NSString *> * searchTitles;

- (instancetype)initWithFrame:(CGRect)frame withHighlight:(BOOL)highlighted;

@end

NS_ASSUME_NONNULL_END
