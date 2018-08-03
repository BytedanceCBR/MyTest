//
//  TTContactsRedPacketDetailView.h
//  Article
//
//  Created by Jiyee Sheng on 8/3/17.
//
//


#import "TTRedPacketDetailBaseView.h"


@class TTRecommendUserModel;


@interface TTContactsRedPacketDetailView : TTRedPacketDetailBaseView

- (void)setContactUsers:(NSArray<TTRecommendUserModel *> *)users;
- (void)setDefaultAvatar:(NSString *)avatar;
@end
