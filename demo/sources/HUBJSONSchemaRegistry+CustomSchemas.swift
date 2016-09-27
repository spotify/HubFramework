import Foundation
import HubFramework

extension HUBJSONSchemaRegistry {
    var gitHubSearchSchemaIdentifier: String { return "gitHub" }
    
    func registerGitHubSearchSchema() {
        let schema = self.createNewSchema()
        schema.viewModelSchema.bodyComponentModelDictionariesPath = schema.createNewPath().go(to: "items").forEach().dictionaryPath()
        
        schema.componentModelSchema.targetDictionaryPath = schema.createNewPath().dictionaryPath()
        schema.componentModelSchema.titlePath = schema.createNewPath().go(to: "name").stringPath()
        schema.componentModelSchema.subtitlePath = schema.createNewPath().go(to: "owner").go(to: "login").run({ input in
            guard let authorName = input as? String else {
                return nil
            }
            
            return "Author: " + authorName
        }).stringPath()
        
        schema.componentTargetSchema.uriPath = schema.createNewPath().go(to: "html_url").urlPath()
        
        self.registerCustomSchema(schema, forIdentifier: self.gitHubSearchSchemaIdentifier)
    }
}
