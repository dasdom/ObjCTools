//  Created by dasdom on 11.08.18.
//  Copyright © 2018 dasdom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SourceEditorMethods : NSObject
+ (void)addImportStatementFromSelectedString:(NSString *)selectedString toLines:(NSMutableArray<NSString *> *)lines;
+ (void)dublicateLine:(NSString *)line lineNumber:(NSInteger)lineNumber inLines:(NSMutableArray<NSString *> *)lines replaceStrings:(BOOL)replaceStrings;
+ (void)sortImportsAndRemoveDublicatesInLines:(NSMutableArray<NSString *> *)lines;
+ (void)hexToUIColorFromSelectedString:(NSString *)selectedString lineNumber:(NSInteger)lineNumber inLines:(NSMutableArray<NSString *> *)lines indentation:(NSString *)indentation contentUTI:(NSString *)contentUTI;
+ (NSString *)declarationForStrings:(NSArray<NSString *> *)selectedLines;
@end
