//
//  TTContactsRedPacketView.h
//  Article
//  通讯录红包组件
//
//  Created by Jiyee Sheng on 8/2/17.
//
//



#import "TTRedPacketBaseView.h"
#import "TTContactsRedPacketManager.h"

@interface TTContactsRedPacketParam : NSObject
@property (nonatomic, copy) NSString *redpacketId;
@property (nonatomic, copy) NSString *redpacketToken;
@property (nonatomic, copy) NSString *redpacketFirstLine;
@property (nonatomic, copy) NSString *redpacketSecondLine;
@property (nonatomic, copy) NSString *redpacketTitle;
@property (nonatomic, copy) NSString *redpacketIconUrl;
@property (nonatomic, copy) NSString *redpacketIconText;

+ (TTContactsRedPacketParam *)paramWithDict:(NSDictionary *)dict;
@end

@interface TTContactsRedPacketView : TTRedPacketBaseView

- (instancetype)initWithFrame:(CGRect)frame type:(TTContactsRedPacketViewControllerType)type param:(TTContactsRedPacketParam *)param;

@property (nonatomic, strong) NSArray *contactUsers;

@end
