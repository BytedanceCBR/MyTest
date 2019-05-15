//
//  TTDiggActivity.h
//  Article
//
//  Created by lishuangyang on 2017/8/24.
//
//
#import "TTDiggContentItem.h"
#import "TTActivityprotocol.h"
#import "TTAcTivityPanelDefine.h"

@interface TTDiggActivity : NSObject<TTActivityProtocol, TTActivityPanelActivityProtocol>

@property (nonatomic, strong)TTDiggContentItem *contentItem;

@end
