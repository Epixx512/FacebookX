#import <substrate.h>
#import <Foundation/Foundation.h>

@interface FacebookXProtocol : NSURLProtocol
@end

@implementation FacebookXProtocol

+ (BOOL)canInitWithRequest:(NSURLRequest *)request {
	if ([NSURLProtocol propertyForKey:@"FacebookXHandled" inRequest:request]) return NO;
	if (([request.URL.host isEqualToString:@"api.facebook.com"] || [request.URL.host isEqualToString:@"api-read.facebook.com"]) && [request.URL.path isEqualToString:@"/restserver.php"]) return YES;
	return NO;
}

+ (NSURLRequest *)canonicalRequestForRequest:(NSURLRequest *)request {
	return request;
}

- (void)startLoading {
	NSURL *url = self.request.URL;
	NSMutableURLRequest *newReq = [self.request mutableCopy];
	if ([url.scheme isEqualToString:@"http"]) {
		NSString *newURLStr = [@"https://" stringByAppendingString:[url.absoluteString substringFromIndex:7]];
		newReq.URL = [NSURL URLWithString:newURLStr];
	}
	if (([url.host isEqualToString:@"api.facebook.com"] || [url.host isEqualToString:@"api-read.facebook.com"]) && [url.path isEqualToString:@"/restserver.php"]) {
		NSString *value = nil;
		NSData *bodyData = newReq.HTTPBody;
		if (bodyData) {
			NSString *body = [[NSString alloc] initWithData:bodyData encoding:NSUTF8StringEncoding];
			NSRange markerRange = [body rangeOfString:[NSString stringWithCString:"name=\"method\"" encoding:NSUTF8StringEncoding]];
			if (markerRange.location != NSNotFound) {
				NSString *remainder = [[body substringFromIndex:markerRange.location + markerRange.length] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
				NSRange newlineRange = [remainder rangeOfString:[NSString stringWithCString:"\n" encoding:NSUTF8StringEncoding]];
				value = remainder;
				if (newlineRange.location != NSNotFound) value = [remainder substringToIndex:newlineRange.location];
				value = [value stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
			}
		}
		if (value) newReq.URL = [NSURL URLWithString:[NSString stringWithFormat:@"https://%@/method/%@", url.host, value]];
	}
	NSURLResponse *response = nil;
	NSError *error = nil;
	[NSURLProtocol setProperty:[NSNumber numberWithBool:YES] forKey:@"FacebookXHandled" inRequest:newReq];
	NSData *data = [NSURLConnection sendSynchronousRequest:newReq returningResponse:&response error:&error];
	if (error) {
		[self.client URLProtocol:self didFailWithError:error];
		return;
	}
	[self.client URLProtocol:self didReceiveResponse:response cacheStoragePolicy:NSURLCacheStorageNotAllowed];
	[self.client URLProtocol:self didLoadData:data];
	[self.client URLProtocolDidFinishLoading:self];
}

- (void)stopLoading {
}

@end

%ctor {
	[NSURLProtocol registerClass:[FacebookXProtocol class]];
}