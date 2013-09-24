#import "AFHTTPClient.h"
#import <Foundation/Foundation.h>

@interface SharedClient : AFHTTPClient

+(SharedClient *) sharedClient;

@end
