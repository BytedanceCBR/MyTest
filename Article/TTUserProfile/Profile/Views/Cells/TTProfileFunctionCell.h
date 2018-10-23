//
//  TTForumTopicCell.h
//  Article
//
//  Created by yuxin on 4/9/15.
//
//

#import <UIKit/UIKit.h>
#import "SSThemed.h"
#import "TTImageView.h"
#import "TTBadgeNumberView.h"
#import "TTSettingMineTabEntry.h"

static const NSInteger TTExploreMyDownloadLabelTag = 1000;


@interface TTProfileFunctionCell : SSThemedTableViewCell

@property (nonatomic,weak) IBOutlet SSThemedLabel * titleLb;
@property (nonatomic,weak) IBOutlet SSThemedImageView *  cellImageView;
@property (nonatomic,weak) IBOutlet SSThemedLabel * accessoryLb;
@property (nonatomic,weak) IBOutlet TTBadgeNumberView *  badgeView;

@property (nonatomic,weak) IBOutlet SSThemedImageView *  rightImageView;

@property (nonatomic,weak) IBOutlet NSLayoutConstraint *  titleLeftMargin;

@property (nonatomic,strong) UISwitch *rightSwitch;
@property (nonatomic, copy)  void(^switchChanged)(); //开关状态变化
@property (nonatomic,strong) NSIndexPath * index;

- (void)refreshHintWithEntry:(TTSettingMineTabEntry *)entry;


- (void)setCellImageName:(NSString*)imageName;

@end
