#!/usr/bin/env zsh
# This script updates the repos folder based on the template folder

# print "🐙 Updating repos based on stack/git/repos-folder-template ..."

# 1️⃣ Define folder paths

if [[ -z "${GIT_REPOS_FOLDER:-}" ]]; then
    print "⚠️  Warning: Skipping sync of git repos since GIT_REPOS_FOLDER variable was not loaded from macstack.json"
    exit 0
fi

repos_folder=${~GIT_REPOS_FOLDER}
repos_folder_template="$MAC_STACK_ROOT/stack/git/repos-folder-template"

if [[ ! -d "$repos_folder_template" ]]; then
    print "⚠️ Warning: Skipping sync of git repos since repos folder template does not exist in stack:\n$repos_folder_template"
    exit 0
fi

# print "  📁 Repos folder:"
# print "     $repos_folder"
# print "  📁 Repos folder template:"
# print "     $repos_folder_template"

# 2️⃣ Recursively iterate through all files and folders in the template folder

issue_messages=() # prepare list of issue messages

function record_issue() {
    # print the issue
    local issue="$1"
    # print "  $issue"

    # append issue to issue message
    issue_message="$issue_message\n  $issue"

    # append issue message to list
    issue_messages+=("$issue_message")
}

for item in "$repos_folder_template"/**/*(N); do
    relative_path="${item#$repos_folder_template/}"

    if [[ -d "$item" ]]; then
        #print "📁 $relative_path"
    else
        # If this is a git-repos.txt file, print each line
        if [[ "${item:t}" == "git-repos.txt" ]]; then
            # Extract the folder path (without the filename)
            relative_folder="${relative_path:h}"

            while IFS= read -r repo_url; do
                # Extract repo name from URL (last path component)
                repo_name="${repo_url##*/}"
                repo_name="${repo_name%.git}"

                repo_folder="$repos_folder/$relative_folder/$repo_name"

                print "🐙 Updating repo $repo_name ..."
                #print "  🐙 URL: $repo_url"

                # prepare issue processing
                issue_message="📁 $repo_folder\n  🐙 $repo_url"

                # Check if folder exists and contains a valid git repo
                if [[ -d "$repo_folder" ]]; then
                    if git -C "$repo_folder" rev-parse --git-dir &>/dev/null; then
                        #print "  ✅ Git repo already exists"

                        # Check for changes
                        status_output=$(git -C "$repo_folder" status --porcelain 2>/dev/null)
                        if [[ -n "$status_output" ]]; then
                            record_issue "⚠️  Has changes"
                        else
                            #print "  ✅ Clean working tree"

                            # Check sync status with remote
                            upstream=$(git -C "$repo_folder" rev-parse --abbrev-ref --symbolic-full-name @{upstream} 2>/dev/null)

                            if [[ -z "$upstream" ]]; then
                                record_issue "⚠️  No remote tracking branch"
                            else
                                rev_list_output=$(git -C "$repo_folder" rev-list --left-right --count HEAD...@{upstream} 2>/dev/null)

                                if [[ -n "$rev_list_output" ]]; then
                                    typeset -a counts=(${(s:	:)rev_list_output})
                                    typeset -i ahead=${counts[1]} behind=${counts[2]}

                                    if (( ahead > 0 && behind > 0 )); then
                                        record_issue "⚠️  Diverged: ↑$ahead ahead AND ↓$behind behind"
                                    elif (( ahead > 0 )); then
                                        #print "  ⬆️ Ahead by $ahead commit(s). Pushing ..."
                                        if git -C "$repo_folder" push 2>&1; then
                                            print "  ✅ Pushed successfully"
                                        else
                                            record_issue "🛑 Push failed"
                                        fi
                                    elif (( behind > 0 )); then
                                        #print "  ⬇️ Behind by $behind commit(s). Pulling ..."
                                        if git -C "$repo_folder" pull 2>&1; then
                                            print "  ✅ Pulled successfully"
                                        else
                                            record_issue "🛑 Pull failed"
                                        fi
                                    else
                                        # print "  ✅ In sync with $upstream"
                                    fi
                                fi
                            fi
                        fi
                    else
                        # Check if folder is empty
                        if [[ -z "$(ls -A "$repo_folder" 2>/dev/null)" ]]; then
                            #print "  ⬇️ Empty folder exists. Cloning ..."
                            if git clone "$repo_url" "$repo_folder" 2>&1; then
                                print "  ✅ Cloned successfully"
                            else
                                record_issue "🛑 Clone failed"
                            fi
                        else
                            record_issue "⚠️  Expected repo folder exists and contains items yet is not a git repo"
                        fi
                    fi
                else
                    # print "  ⬇️ Creating repo folder and cloning repo..."
                    if git clone "$repo_url" "$repo_folder" 2>&1; then
                        print "  ✅ Cloned successfully"
                    else
                        record_issue "🛑 Clone failed"
                    fi
                fi
            done < "$item"
        else
            print "📄 The template contains an unrelated file that will be ignored: $relative_path"
        fi
    fi
done

# 3️⃣ Alert user to all repos that need manual attention

if [[ ${#issue_messages[@]} -gt 0 ]]; then
    print "\n🚨 The following repos need manual attention:"
    for issue_message in "${issue_messages[@]}"; do
        print "$issue_message"
    done
    print ""
fi
