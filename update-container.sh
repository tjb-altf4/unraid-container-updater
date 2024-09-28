#!/bin/bash

# Directory containing Unraid templates
TEMPLATE_DIR="/boot/config/plugins/dockerMan/templates-user"

# Function to search for templates
search_templates() {
  local repository="$1"
  local template_pattern="$2"
  local template_array=()

  # Iterate through all Unraid templates in the directory
  for template in "$TEMPLATE_DIR"/*.xml; do
    # Check if the template contains <Repository> element matching the specified repository
    if grep -q "<Repository>$repository" "$template"; then
      # Extract the value of <Name> element
      local template_value=$(sed -n 's|.*<Name>\(.*\)</Name>.*|\1|p' "$template")
      
      # Check if TEMPLATE_PATTERN is set and if the <Name> element matches the pattern
      if [[ -z "$template_pattern" || "$template_value" == *"$template_pattern"* ]]; then
        template_array+=("$template_value")
      fi
    fi
  done

  # Return the array
  echo "${template_array[@]}"
}

# Function to update the <Repository> element with a new tag
update_templates() {
  local repository="$1"
  local new_tag="$2"

  # Iterate through all Unraid templates in the directory
  for template in "$TEMPLATE_DIR"/*.xml; do
    # Check if the template contains <Repository> element matching the specified repository
    if grep -q "<Repository>$repository" "$template"; then
      # Replace the <Repository> element with the new tag
      sed -i "s|<Repository>$repository:.*</Repository>|<Repository>$repository:$new_tag</Repository>|" "$template"
    fi
  done
}

# Function to update containers using the updated templates
update_containers() {
  local templates=("$@")
  local template_names=$(IFS='*'; echo "${templates[*]}")

  # Apply updated template changes
  /usr/bin/php -q /usr/local/emhttp/plugins/dynamix.docker.manager/scripts/update_container "$template_names"
}

# Check if at least two arguments are provided
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 [-f|--force] <repository> <new_tag> [template_pattern]"
  exit 1
fi

# Check for force flag
FORCE_UPDATE=false
if [[ "$1" == "-f" || "$1" == "--force" ]]; then
  FORCE_UPDATE=true
  shift
fi

# Assign parameters to variables
REPOSITORY="$1"
NEW_TAG="$2"
TEMPLATE_PATTERN="${3:-}"

# Call the search_templates function and store the result in TEMPLATES
TEMPLATES=$(search_templates "$REPOSITORY" "$TEMPLATE_PATTERN")

# Check if TEMPLATES array is empty
if [[ -z "$TEMPLATES" ]]; then
  echo "No templates found."
  exit 0
fi

# Print the array
echo "Templates found:"
for template in $TEMPLATES; do
  echo "$template"
done

# Prompt user to confirm changes if not forced
if [[ "$FORCE_UPDATE" == false ]]; then
  read -p "Update the list templates for $REPOSITORY with the new tag $NEW_TAG? (y/n): " confirm
  if [[ "$confirm" != "y" ]]; then
    echo "No changes made."
    exit 0
  fi
fi

# Call the update_templates function to update the <Repository> element with the new tag
update_templates "$REPOSITORY" "$NEW_TAG"
echo "Templates updated successfully."

# Call the update_containers function to apply updated template changes
update_containers $TEMPLATES
echo "Containers updated successfully."

exit