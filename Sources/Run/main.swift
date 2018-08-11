import App
import Service
import Vapor
import Foundation

do {
    let accessToken = Environment.get("access_token")!
    let verificationToken = Environment.get("verification_token")!
    let botID = Environment.get("bot_id")!
    
    let bot = try SlackBot(
        accessToken: accessToken,
        verificationToken: verificationToken,
        id: botID
    )
    
    bot.handleMessage { message in
//        try bot.respondEphemerally(to: message, with: ["you just said \"", message.text, "\""])
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
        try bot.respond(
            to: message,
            with: "hi",
            attachments: [
                .init(
                    title: .init(contents: ["<sup> ", message.user]),
                    author: .init(name: ["<hello> ", message.user])
                )
            ],
            style: .threaded
        )
        
        try bot.respond(
            to: message,
            with: "hi",
            attachments: [
                .init(
                    title: .init(contents: ["<sup> ", message.user]),
                    author: .init(name: ["<hello> ", message.user])
                )
            ],
            style: .inline
        )
    }
    
    try bot.start()
} catch {
    print(error)
    exit(1)
}
