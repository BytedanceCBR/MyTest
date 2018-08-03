//
//  TTLiveMessageNormalReplyCell.m
//  TTLive
//
//  Created by matrixzk on 3/31/16.
//
//

#import "TTLiveMessageNormalReplyCell.h"
#import "TTLiveCellNormalContentView.h"


@interface TTLiveMessageNormalReplyCell ()
@end

@implementation TTLiveMessageNormalReplyCell

- (void)prepareForReuse
{
    [super prepareForReuse];
}

- (void)layoutSubviews
{
    CGSize normalContentViewSize = [TTLiveCellHelper sizeOfNormalContentViewWithMessage:self.message];
    CGSize replyedNormalContentViewSize = [TTLiveCellHelper sizeOfNormalContentViewWithMessage:self.message.replyedMessage];
    
    CGFloat suitableWidth = MAX(normalContentViewSize.width - OriginXOfCellContent()*2, replyedNormalContentViewSize.width);
    
    self.normalContentView.frame = CGRectMake(self.isIncomingMsg ? OffsetOfBubbleImageArrow() : 0, 0,
                                              suitableWidth + OriginXOfCellContent()*2,
                                              normalContentViewSize.height);
    
    self.replyedNormalContentView.frame = CGRectMake(self.isIncomingMsg ? CGRectGetMinX(self.normalContentView.frame) + LeftPaddingOfRefMessageView() : CGRectGetMaxX(self.normalContentView.frame) - replyedNormalContentViewSize.width - LeftPaddingOfRefMessageView(),
                                                     normalContentViewSize.height,
                                                     replyedNormalContentViewSize.width,
                                                     replyedNormalContentViewSize.height);
    
    self.containerView.frame = CGRectMake(0, 0,
                                          OffsetOfBubbleImageArrow() + suitableWidth + LeftPaddingOfRefMessageView()*2,
                                          CGRectGetMaxY(self.replyedNormalContentView.frame) + BottomPaddingOfRefMessageView());
    
    // layout incoming or outgoing cell type
    [super layoutSubviews];
}

- (void)setupCellWithMessage:(TTLiveMessage *)message
{
    [super setupCellWithMessage:message];
    
    [self.normalContentView showContentWithMessage:message isIncomingMsg:self.isIncomingMsg];
    [self.replyedNormalContentView showContentWithMessage:message.replyedMessage isIncomingMsg:self.isIncomingMsg];
}

@end
