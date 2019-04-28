//
//  TTLiveStatusView.h
//  Article
//
//  Created by 杨心雨 on 16/8/17.
//
//

#import "SSThemed.h"
#import "Live.h"

@interface TTLiveStatusView : SSThemedView

- (void)updateStatus:(Live *)live status:(NSInteger)status;

@end
