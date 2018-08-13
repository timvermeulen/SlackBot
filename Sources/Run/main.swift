import App
import Service
import Vapor
import Foundation

do {
    let clientID =      Environment.get("client_id")!
    let clientSecret =  Environment.get("client_secret")!
    let signingSecret = Environment.get("signing_secret")!
    
    let bot = try SlackBot(
        oauth: .init(
            clientID: .init(rawValue: clientID),
            clientSecret: .init(rawValue: clientSecret),
            scopes: [.channelsHistory, .chatWrite, .usersRead, .reactionsWrite]
        ),
        signingSecret: .init(rawValue: signingSecret)
    )
    
    bot.handleMessage { bot, message in
        _ = try bot.get(bot.team).do { team in
            print(team)
        }
        
        try bot.react(to: message, with: Emoji.strawberry)

//        try bot.get(message.user).do { user in
//            // TODO: log error
//            try? bot.respondEphemerally(
//                to: message,
//                with: ["you just said \"", message.text, "\", ", user.username]
//            )
//        }.catch { error in
//            print(error)
//        }
        
//        try bot.respond(to: message, with: ["wazzup ", message.user], attachments: [
//            .init(
//                contents: "Body 1",
//                color: .danger,
//                thumbnailURL: "https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201803230252",
//                fields: [
//                    .init(title: "title 1", contents: "contents 1", isShort: true),
//                    .init(title: "title 2", contents: "contents 2", isShort: true)
//                ],
//                footer: .init(
//                    contents: ["hey ", message.user],
//                    iconURL: "https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201803230252"
//                )
//            ),
//            .init(
//                contents: "Body 2",
//                pretext: ["definitely you, ", message.user],
//                title: .init(contents: ["sup ", message.user], link: "https://api.slack.com/"),
//                author: .init(name: ["it's you, ", message.user], link: "https://api.slack.com/")
//            )
//        ], style: .threaded)
    }
    
    try bot.start()
} catch {
    print(error)
    exit(1)
}
