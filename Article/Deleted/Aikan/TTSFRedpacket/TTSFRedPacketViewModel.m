//
//  TTSFRedPacketViewModel.m
//  Article
//
//  Created by 冯靖君 on 2017/12/6.
//

#import "TTSFRedPacketViewModel.h"

@implementation TTSFRedPacketViewModel

- (instancetype)initWithSponsor:(TTSponsorModel *)sponsor
                      shareInfo:(NSDictionary *)shareInfo
                         amount:(NSInteger)amount
                           type:(TTSFRedPacketViewType)viewType
                          token:(NSString *)token
{
    self = [super init];
    if (self) {
        self.token = token;
        self.sponsor = sponsor;
        self.shareInfo = shareInfo;
        self.viewType = viewType;
        self.amount = [NSString stringWithFormat:@"%.2f",amount / 100.0];
        switch (viewType) {
            case TTSFRedPacketViewTypeMahjongWinner:
                self.repacketTitle = @"恭喜你获得發财红包";
                break;
            case TTSFRedPacketViewTypeRain:
                self.repacketTitle = @"恭喜你获得财神红包";
                break;
            case TTSFRedPacketViewTypePostTinyVideo:
                self.repacketTitle = @"给你发来小视频红包";
                break;
            case TTSFRedPacketViewTypeTinyVideo:
                self.repacketTitle = @"给你发来小视频红包";
                break;
            case TTSFRedPacketViewTypeInviteNewUser:
                self.repacketTitle = @"送你一个拉新红包";
                break;
            case TTSFRedPacketViewTypeNewbee:
                self.repacketTitle = @"送你一个新人红包";
                break;
            case TTSFRedPacketViewTypeSunshine:
                self.repacketTitle = @"送你一个见面礼红包";
                break;
            default:
                break;
        }
    }
    return self;
}

@end
