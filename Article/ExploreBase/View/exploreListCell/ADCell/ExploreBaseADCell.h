//
//  ExploreBaseADCell.h
//  Article
//
//  Created by SunJiangting on 14-9-14.
//
//

#import "ExploreCellBase.h"
#import "SSThemed.h"
#import "TTImageView.h"
#import "ExploreOrderedData+TTBusiness.h"
#import "TTTouchContext.h"


@interface ExploreBaseADCell : ExploreCellBase

@property(nonatomic, strong, nullable)SSThemedView    *backgroundColorView;
@property(nonatomic, strong, nullable)SSThemedLabel   *titleLabel;
@property(nonatomic, strong, nullable)TTImageView     *displayImageView;
@property(nonatomic, strong, nullable)SSThemedView    *imageMaskView;
/// 推广  等字样
@property(nonatomic, strong, nullable)UILabel         *promoteLabel;
@property(nonatomic, strong, nullable)TTImageView     *iconView;
/// 谁谁谁 的广告，广告来源
@property(nonatomic, strong, nullable)SSThemedLabel   *sourceLabel;
@property(nonatomic, strong, nullable)SSThemedLabel   *timeLabel;
@property(nonatomic, strong, nullable)SSThemedLabel   *commentLabel;
/// +号，点击出现不感兴趣
@property(nonatomic, strong, nullable)SSThemedButton  *accessoryButton;


@property(nonatomic, strong, nullable)SSThemedView    *separatorView;


@property(nonatomic, strong, nullable)SSThemedView    *bottomView;

@property(nonatomic, weak, nullable)ExploreOrderedData *orderedData;

+ (CGFloat)preferredContentTextSize;

//+ (ExploreBaseADCell * _Nullable)dequeueReusableCellInTableView:(UITableView * _Nonnull) tableView
//                                           dataSource:(ExploreOrderedData * _Nonnull) dataSource
//                                                refer:(NSUInteger)refer;

@property (nonatomic, assign)BOOL          readPersistAD;

@end
//extern _Nullable Class ExploreADCellClassFromDataSource(ExploreOrderedData * dataSource, NSString ** reuseIdentifier);
/// 广告类型cell的各种间距
extern UIEdgeInsets const ExploreADCellContentInset;

@interface ExploreBaseADCell (TTAdCellLayoutInfo) <TTAdCellLayoutInfo>
- (nonnull NSDictionary *)adCellLayoutInfo;
@end
