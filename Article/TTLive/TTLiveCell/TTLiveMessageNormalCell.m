//
//  TTLiveMessageNormalCell.m
//  TTLive
//
//  Created by matrixzk on 3/30/16.
//
//

#import "TTLiveMessageNormalCell.h"
#import "TTLiveMessage.h"
#import "TTLiveCellNormalContentView.h"

@interface TTLiveMessageNormalCell ()
@end

@implementation TTLiveMessageNormalCell

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)layoutSubviews
{
    CGSize sizeOfNormalContentView = [TTLiveCellHelper sizeOfNormalContentViewWithMessage:self.message];
    self.normalContentView.frame = (CGRect){self.isIncomingMsg ? OffsetOfBubbleImageArrow() : 0, 0, sizeOfNormalContentView};
    self.containerView.frame = CGRectMake(0, 0, CGRectGetWidth(self.normalContentView.frame), sizeOfNormalContentView.height);
    
    // layout incoming or outgoing cell type
    [super layoutSubviews];
}

- (void)setupCellWithMessage:(TTLiveMessage *)message
{
    [super setupCellWithMessage:message];
    [self.normalContentView showContentWithMessage:message isIncomingMsg:self.isIncomingMsg];
}

@end
