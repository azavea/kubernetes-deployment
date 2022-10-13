# Obsidian
Created: 2022-06-29, 19:41

This documentation is intended to be browsed using the [[#^obsidian|Obsidian]] app.  Individual documentation items should be kept short and linked to all associated documentation items.  Hashtags may be included to categorize entries to aid in navigation.  

Links in Obsidian are made in [[#^wikilink|wikilink]] style.  This will make it harder for non-Obsidian users to browse this repository, but the simplicity will benefit note writers.  Links will normally be place in line, but relevant notes that did not find a natural place to mention in the body can be linked explicitly in the endnotes in "see also" fashion.

## Templates
When creating new notes, please use an appropriate template.  This will ensure that notes are dated—useful for identifying out-of-date information—and consistently formatted.  In Obsidian, after creating a new note and adding a title, use the `Ctrl+T` hotkey to insert the [[Entry]] template.  Common note types may have their own templates added in the future as need arises.

## Graph view
Obsidian provides a graph view (accessible via the `Ctrl+G` hotkey) which provides a convenient way to navigate through existing topics.  We aim to cultivate the most useful graph view possible, as this ensures the most accessible knowledge base.  Submissions to this repository should be reviewed with an eye toward effective linking.

## Git and collaboration
This knowledge base is tracked via Git as a means to collectively work on it.  Bear in mind that Obsidian is not naturally intended for collaborative work, and so there is no native support for Git or other centralized storage.  We may look into [[#^obsidian-sync|Obsidian sync]] as a means for collaborative storage in the future as that service evolves, but it does not currently appear viable.  There is also a community-supported [[#^obsidian-git|plugin]] that allows for changes in an Obsidian vault to be tracked in git through the Obsidian interface, but it is not very mature and may not work for us.

Downsides of using a git repository: 
1. Moving notes within Obsidian will not be properly tracked
	- Moving notes via `git mv` will not benefit from automatic update of links that refer to the target file and is discouraged
	- This is a justification for using a flat directory structure
2. Merge conflicts may be difficult to resolve
3. Keeping up-to-date on the current `master` will have to be a manual affair

This is part of the experiment of using Obsidian for this repo: to see if it is practical for a large number of collaborators to maintain a single vault.

### Local customization
Be aware that the `.obsidian` directory is not tracked by git.  This means that you can feel free to customize your Obsidian vault with plugins and themes or adjust its appearance to suit your own purposes.  However, if your plugins affect the displayed content of a note (like, for instance, Dataview), they may not be reflected in all cloned instances of these documents.  If there is consensus, it is possible to adjust the default plugin list in the future.

For the moment, the default core plugins are enabled as well as the tag pane and templates core plugins.  Also available by default is the Sliding Panes community plugin, which makes viewing many documents concurrently much more elegant.  Feel free to remove this from your local instance if you prefer.

## Links/Tags/References
1. Obsidian [website](https://obsidian.md/) ^obsidian
2. [Wikilink](https://en.wikipedia.org/wiki/Help:Link) syntax ^wikilink
3. #documentation_style 
4. [[Maps of Content]]
5. [Obsidian sync](https://obsidian.md/sync) ^obsidian-sync
6. [Obsidian git plugin](https://github.com/denolehov/obsidian-git) ^obsidian-git