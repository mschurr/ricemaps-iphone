
/*
 Provides an interface for determining whether or not the application is currently accessing the network and displaying the activity indicator accordingly.
 
 Both registerNetworkActivity and unregisterNetworkActivity are thread-safe and can be called from any thread.
 */

#import <Foundation/Foundation.h>

@interface NetworkActivityManager : NSObject

+ (NetworkActivityManager *) standardNetworkActivityManager;
- (void) registerNetworkActivity;
- (void) unregisterNetworkActivity;

@end
