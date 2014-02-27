//
//  CachedRemoteJSONData.m
//  Rice University Map
//
//  Created by Matthew Schurr on 1/29/14.
//  Copyright (c) 2014 Schurr Solutions. All rights reserved.
//

#import "CachedRemoteJSONData.h"
#import "NetworkActivityManager.h"

@interface CachedRemoteJSONData ()
@property (strong, nonatomic) id deserializedJSONObject;
@property (strong, nonatomic) NSError *lastError;
@end

@implementation CachedRemoteJSONData

/* Returns the deserialized JSON object from the local cache.
   If the local cache is empty, returns nil. */
- (id) deserializedJSONObject
{
    if(!_deserializedJSONObject) {
        
    }
    return _deserializedJSONObject;
}

/* Refreshes the data from the remote server.
   If the refresh fails, the local cache is preserved.
 */
- (void) refresh
{
    
}

/* Returns the last error that occured in this class.
 */
- (NSError *) lastError
{
    return nil;
}

- (id) initWithURL: (NSString *) url expirationTime: (NSTimeInterval) time
{
    self = [super init];
    
    if(self) {
        
    }
    
    return self;
}

- (id) init
{
    return nil;
}

@end
