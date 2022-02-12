//
//  RssItem.h
//  PodcastApp
//
//  Created by Astrid on 2022/2/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RssItem : NSObject

@property (nonatomic, strong) NSMutableString* rssTitle;
@property (nonatomic, strong) NSMutableString* rssDescription;
@property (nonatomic, strong) NSMutableString* rssPubDate;
@property (nonatomic, strong) NSString* rssAudioUrl;
@property (nonatomic, strong) NSString* rssEpImageUrl;

- (instancetype)initWithRssTitle:(NSMutableString*)rssTitle initWithRssDescription:(NSMutableString*)rssDescription initWithRssPubDate:(NSMutableString*)rssPubDate initWithAudioUrl:(NSString*)rssAudioUrl initWithEpImageUrl:(NSString*)rssEpImageUrl;

- (NSString*) description;

@end

NS_ASSUME_NONNULL_END
