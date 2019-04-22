//
//  TTVLastReadItem.h
//  Article
//
//  Created by pei yun on 2017/4/7.
//
//

#import "TTVTableViewItem.h"
#import "TTVLastRead.h"

@interface TTVLastReadItem : TTVTableViewItem

@property (nonatomic, strong) TTVLastRead *lastRead;

@end

@interface TTVLastReadCell : TTVTableViewCell

@end
