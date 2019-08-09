//  Created by dasdom on 09.08.19.
//  Copyright © 2019 dasdom. All rights reserved.
//

#import "NSString+RangeOfRegex.h"

@implementation NSString (RangeOfRegex)

- (NSRange)rangeOfFirstMatchForRegex:(NSString *)regex {
    
    NSError *error = nil;
    NSRegularExpression *equalRegex = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
    
    return [equalRegex rangeOfFirstMatchInString:self options:0 range:NSMakeRange(0, self.length)];
}

@end
