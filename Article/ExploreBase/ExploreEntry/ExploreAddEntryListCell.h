//
//  ExploreAddEntryListCell.h
//  Article
//
//  Created by Zhang Leonardo on 14-11-23.
//
//

#import "SSThemed.h"
#import "ExploreEntry.h"
#import "TTImageView.h"

@class ExploreAddEntryListCell;

@protocol ExploreAddEntryListCellDelegate <NSObject>

- (void)channelListCell:(ExploreAddEntryListCell *)cell subscribeChannel:(ExploreEntry *)channel;
- (void)channelListCell:(ExploreAddEntryListCell *)cell unsubscribeChannel:(ExploreEntry *)channel;

@end


@interface ExploreAddEntryListCell : SSThemedTableViewCell

@property (nonatomic, strong) ExploreEntry *channelInfo;
@property (nonatomic, weak) id<ExploreAddEntryListCellDelegate> cellDelegate;

@property (nonatomic, strong) TTImageView *channelImageView;
@property (nonatomic, strong) UILabel *channelNameLabel;
@property (nonatomic, strong) UILabel *detailLabel;
@property (nonatomic, strong) UIButton *subscribeButton;

@property (nonatomic, assign) CGFloat imageLeftPadding;
@property (nonatomic, assign) CGFloat buttonRightPadding;
@property (nonatomic, assign) CGFloat bottomLineLeftPadding;
@property (nonatomic, assign) CGFloat bottomLineRightPadding;

+ (CGFloat)defaultHeight;

- (void)fillWithChannelInfo:(ExploreEntry *)channelInfo;

- (void)setSubscribed:(BOOL)isSubscribed;

@end
