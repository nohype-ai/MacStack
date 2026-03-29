## Grok Conversations Export Script

* In order to turn Grok conversations into local resources integrated into existing file system structures and available as context to IDE AI agents, we need a way to export them quickly into markdown files. This script does that.
* To do the export run `python export_conversations.py`
* The script expects a `conversations.json` file in the same folder which would be the (renamed) central file from the xAI account data export. You can get a new current export at <https://accounts.x.ai/data>.

## Data Structure

The `conversations.json` file has the following structure:

```json
{
  "conversations": [
    {
      "conversation": {
        "id": "String (UUID)",
        "title": "String",
        "create_time": "String (ISO 8601)",
        "modify_time": "String (ISO 8601)",
        "user_id": "String (UUID)",
        ...
      },
      "responses": [
        {
          "response": {
            "sender": "human", 
            "message": "String (Content)",
            "create_time": "Object | String",
            "model": "String (e.g. grok-v1)",
            ...
          }
        },
        ...
      ]
    },
    ...
  ]
}
```
