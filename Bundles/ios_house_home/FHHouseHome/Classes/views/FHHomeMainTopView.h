//
//  FHHomeMainTopView.h
//  AKCommentPlugin
//
//  Created by 谢飞 on 2019/11/26.
//

#import <UIKit/UIKit.h>
#import "HMSegmentedControl.h"
#import "FHHomeSearchPanelView.h"

NS_ASSUME_NONNULL_BEGIN

@interface FHHomeMainTopView : UIView
@property(nonatomic,strong)HMSegmentedControl *segmentControl;
@property(nonatomic,strong)HMSegmentedControl *houseSegmentControl;
@property(nonatomic,strong)FHHomeSearchPanelView *searchPanelView;
@property (nonatomic, strong) UIButton *searchBtn;
@property (nonatomic, strong) UIButton *mapSearchBtn;
@property (nonatomic, strong) UILabel *mapSearchLabel;

@property(nonatomic,copy) void (^indexChangeBlock)(NSInteger index);
@property(nonatomic,copy) void (^indexHouseChangeBlock)(NSInteger index);

- (void)updateSegementedTitles:(NSArray <NSString *> *)titles andSelectIndex:(NSInteger)index;

- (void)changeSearchBtnAndMapBtnStatus:(BOOL)isShowSearchBtn;

- (void)updateMapSearchBtn;

- (void)changeBackColor:(NSInteger)index;

- (void)showUnValibleCity;

@end

NS_ASSUME_NONNULL_END
