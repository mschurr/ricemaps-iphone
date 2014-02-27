//
//  RUMapDataBuses.h
//  Rice University Map
//
//  Created by Matthew Schurr on 1/29/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import <Foundation/Foundation.h>

#define RUMapDataBuses_LONGITUDE @"Longitude"
#define RUMapDataBuses_LATITUDE @"Latitude"
#define RUMapDataBuses_LABEL @"Name"

@interface RUMapDataBuses : NSObject
@property (strong, nonatomic, readonly) NSArray *busLocations;
- (void) startMonitoring;
- (void) stopMonitoring;
@end
