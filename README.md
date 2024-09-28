# unraid-container-updater
### Update Unraid container tag from command line

This tool is targeted for bulk updates of container tags.

This tool works by searching for templates using the specified container repository/image-name using the `REPOSITORY` parameter. 
A secondary filter `TEMPLATE_PATTERN` can be applied to create filter criteria based on container name. `NEW_TAG` variable is the container tag you want the containers to be updated to.

Workflow:
1. Search for all templates matching provided `REPOSITORY`
2. If specified, filter found templates by `TEMPLATE_PATTERN`
3. Show user templates/containers to be updated
4. User prompted to proceed or abort
5. Template updates are applied
6. Restart container with updated template values

## Remarks:
- WARNING: This script does not check if tags exist, invalid tags can result in invalid templates, leading to container disappearing from Docker page.
- Invalid templates can be recovered manually though Docker page "Add Container > Select a Template" (Find old container name), or container may be recoverable through re-running script with valid tag (untested).
- Test on a single container using the `TEMPLATE_PATTERN` to build up confidence with the tool
- Container templates are backed up as part of the Unraid OS flash backup, it is highly recommended to do this backup before using this script.


## Example usage:
```bash
REPOSITORY="spacemeshos/post-service"
NEW_TAG="v0.7.11"
TEMPLATE_PATTERN="smh-post-"    # optional template name filter

./update-container.sh $REPOSITORY $NEW_TAG $TEMPLATE_PATTERN
```

### Normal usage
Usage where user can review affected templates and choose to update, or abort changes.
```bash
./update-container.sh spacemeshos/post-service v0.7.13 smh-post-
```
```
Templates found:
smh-post-01
smh-post-02
smh-post-03
smh-post-04
smh-post-05
smh-post-06
smh-post-07
smh-post-08
smh-post-09
Update the list templates for spacemeshos/post-service with the new tag v0.7.13? (y/n): y
Templates updated successfully.
Containers updated successfully.
```

### Advanced usage (DANGER)
This usage bypasses user confirmation with use of a `--force` or `-f` flag, this is intended for advanced users wishing to script updates to multiple containers.
```bash
./update-container.sh --force spacemeshos/post-service v0.7.13 smh-post-
./update-container.sh -f spacemeshos/go-spacemesh v1.7.1 smh-node-
```
```
Templates found:
smh-post-01
smh-post-02
smh-post-03
smh-post-04
smh-post-05
smh-post-06
smh-post-07
smh-post-08
smh-post-09
Templates updated successfully.
Containers updated successfully.
```
```
Templates found:
smh-node-01
smh-node-02
Templates updated successfully.
Containers updated successfully.
```