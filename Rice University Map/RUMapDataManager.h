//
//  RUMapDataManager.h
//  Rice University Map
//
//  Created by Matthew Schurr on 1/28/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RUMapDataResult.h"
#import "RUMapDataLocation.h"
#import "RUMapDataCourse.h"
#import "RUMapDataPerson.h"

@interface RUMapDataManager : NSObject
@property (nonatomic, readonly) double initialLongitude;
@property (nonatomic, readonly) double initialLatitude;
- (NSArray *) searchResultsForQuery: (NSString *) searchQuery;
- (void) performUpdateNotifyTarget: (id) target Action: (SEL) selector;
- (BOOL) needsUpdate;
@end
