import json
import os
import re
from datetime import datetime

def sanitize_filename(filename):
    """Sanitize the filename to remove invalid characters but keep spaces."""
    # Remove characters that are not allowed in filenames
    filename = re.sub(r'[\\/*?:"<>|]', "", filename)
    # Convert tabs/newlines to spaces
    filename = re.sub(r'[\t\n\r]', " ", filename)
    # Remove multiple spaces
    filename = re.sub(r'\s+', " ", filename).strip()
    # Truncate to a reasonable length
    return filename[:100]

def format_timestamp(ts_str):
    """Format the ISO timestamp to a more readable format."""
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d %H:%M:%S")
    except Exception:
        return ts_str

def get_date_prefix(ts_str):
    """Get YYYY-MM-DD from timestamp string."""
    try:
        dt = datetime.fromisoformat(ts_str.replace("Z", "+00:00"))
        return dt.strftime("%Y-%m-%d")
    except Exception:
        return "Unknown_Date"

def main():
    input_file = "conversations.json"
    output_dir = "conversations_export"

    if not os.path.exists(output_dir):
        os.makedirs(output_dir)

    print(f"Loading {input_file}...")
    try:
        with open(input_file, "r") as f:
            data = json.load(f)
    except FileNotFoundError:
        print(f"Error: {input_file} not found.")
        return

    conversations = data.get("conversations", [])
    print(f"Found {len(conversations)} conversations.")

    for i, item in enumerate(conversations):
        # Extract conversation details
        conv_meta = item.get("conversation", {})
        responses = item.get("responses", [])
        
        title = conv_meta.get("title", f"conversation_{i+1}")
        if not title:
            title = f"conversation_{i+1}"
            
        conv_id = conv_meta.get("id", str(i))
        create_time = conv_meta.get("create_time", "")
        
        # Generate filename with date prefix and spaces
        base_filename = sanitize_filename(title)
        date_prefix = get_date_prefix(create_time)
        
        filename = f"{date_prefix} {base_filename}.md"
        file_path = os.path.join(output_dir, filename)
        
        # Handle duplicate filenames
        if os.path.exists(file_path):
            filename = f"{date_prefix} {base_filename} {conv_id[:8]}.md"
            file_path = os.path.join(output_dir, filename)

        with open(file_path, "w") as f:
            # Write Header
            f.write(f"# {title}\n\n")
            if create_time:
                f.write(f"**Date:** {format_timestamp(create_time)}\n")
            f.write(f"**ID:** {conv_id}\n\n")
            f.write("---\n\n")

            # Extract actual response object
            processed_msgs = []
            for resp_wrapper in responses:
                resp = resp_wrapper.get("response", {}) if "response" in resp_wrapper else resp_wrapper
                processed_msgs.append(resp)
            
            for msg in processed_msgs:
                sender = msg.get("sender", "")
                text = msg.get("message", "")
                
                # Determine role label
                if sender == "human":
                    role = "User"
                else:
                    # It's Grok/Model
                    model_name = msg.get("model", "Grok")
                    role = f"Grok ({model_name})" if model_name else "Grok"

                f.write(f"### {role}\n\n")
                f.write(f"{text}\n\n")
                f.write("---\n\n")

    print(f"Successfully exported {len(conversations)} conversations to '{output_dir}'.")

if __name__ == "__main__":
    main()
