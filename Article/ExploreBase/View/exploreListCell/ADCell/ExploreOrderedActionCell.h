//
//  ExploreOrderedActionCell.h
//  Article
//
//  Created by SunJiangting on 14-9-11.
//
//

#import "ExploreBaseADCell.h"
#import "SSThemed.h"
#import "ExploreActionButton.h"

@class TTImageView;
/// 应用下载类型的内嵌型广告
@interface ExploreOrderedActionCell : ExploreBaseADCell
@property (nonatomic, strong) SSThemedLabel        *nameLabel;
@property (nonatomic, strong) ExploreActionButton  *actionButton;
@end

/// 小图模式下载类型广告
@interface ExploreOrderedActionSmallCell : ExploreOrderedActionCell

@end
