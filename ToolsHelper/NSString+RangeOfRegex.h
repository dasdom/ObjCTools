//  Created by dasdom on 09.08.19.
//  Copyright © 2019 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (RangeOfRegex)
- (NSRange)rangeOfFirstMatchForRegex:(NSString *)regex;
@end
