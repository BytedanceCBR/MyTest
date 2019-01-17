//
//  MockRentHouseListDS.m
//  Demo
//
//  Created by leo on 2018/11/18.
//  Copyright © 2018 com.haoduofangs. All rights reserved.
//

#import "MockRentHouseListDS.h"
#import "FlatRawTableRepository.h"


@interface MockRentHouseListDS ()<FlatRawTableRepository>

@end

@implementation MockRentHouseListDS

- (instancetype)init
{
    self = [super init];
    if (self) {

    }
    return self;
}

- (NSInteger)dataCount {
    return 30;
}

- (nonnull id)modelAtIndexPath:(nonnull NSIndexPath *)indexPath {
    return nil;
}

- (NSInteger)numberOfSections {
    return 1;
}

- (NSInteger)numberOfRowInSection:(NSInteger)section {
    return 30;
}

@end
