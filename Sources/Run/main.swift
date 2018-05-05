import App
import Service
import Vapor
import Foundation

do {
    let accessToken = Environment.get("access_token")!
    let verificationToken = Environment.get("verification_token")!
    let botID = Environment.get("bot_id")!
    
    let bot = try SlackBot(accessToken: accessToken, verificationToken: verificationToken, id: botID)
    
    bot.handleMessage { message in
        let attachments: [Attachment] = [
            Attachment(contents: "Body 1", color: .danger, thumbnailURL: "https://www.apple.com/ac/structured-data/images/knowledge_graph_logo.png?201803230252", fields: [Attachment.Field(title: "title 1", contents: "contents 1", isShort: true), Attachment.Field(title: "title 2", contents: "contents 2", isShort: true)], footer: Attachment.Footer(contents: ["hey ", message.user])),
            Attachment(contents: "Body 2", pretext: ["definitely you, ", message.user], title: Attachment.Title(contents: ["sup ", message.user], link: "https://api.slack.com/"), author: Attachment.Author(name: ["it's you, ", message.user], link: "https://api.slack.com/"))
        ]
        
        try bot.respondEphemerally(to: message, with: ["wazzup ", message.user], attachments: attachments)
    }
    
    bot.addSlashCommand(at: "slash-command", "crypto") { request, client in
        fatalError()
    }
    
    try bot.start()
} catch {
    print(error)
    exit(1)
}
