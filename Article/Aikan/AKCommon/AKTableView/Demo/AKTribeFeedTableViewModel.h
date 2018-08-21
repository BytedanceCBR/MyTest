//
//  AKTribeFeedTableViewModel.h
//  Article
//
//  Created by 冯靖君 on 2018/4/16.
//

#import "AKTableViewModel.h"

@interface AKTestTableViewCellModel : NSObject <AKTableViewDatasourceProtocol>

@property (nonatomic, copy) NSNumber *value;

@end

@interface AKTribeFeedTableViewModel : AKTableViewModel

@end
