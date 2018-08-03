//
//  TTBuryActivity.h
//  Article
//
//  Created by lishuangyang on 2017/8/29.
//
//

#import "TTBuryContentItem.h"
#import "TTActivityprotocol.h"
#import "TTActivityPanelDefine.h"

@interface TTBuryActivity : NSObject<TTActivityProtocol, TTActivityPanelActivityProtocol>

@property (nonatomic, strong)TTBuryContentItem *contentItem;


@end
