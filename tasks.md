---

kanban-plugin: board

---

## In Progress

- [ ] Make website viable!!!


## Backlog

- [ ] MacStack itself must be excluded from brew-clip #bug
- [ ] The script for force adopting apps into Homebrew is essentially a PoC fix of our regular update procedure which apparently does not bring many casks properly into Homebrew if that software (mostly GUI apps) was already installed on the system outside of Homebrew. We should bring those checks into the regular update procedure. #bug
- [ ] Review what should move from Nohype AI stack into MacStack itself. For example right now, macstack is an entry in the Nohype AI Brewfile, shouldn't macstack keep itself alive? there are also other elements in the Nohype AI stack that are general enough or even essential to MacStack.
- [ ] bring the other commands beyond `mack` from bin folder into `mack` and alias them, document the other commands
- [ ] Integrate knowledge base from cloud folder into this repo's /documentation folder and into my stack, dissolve the external knowledge base entirely since I never tap into it anymore
- [ ] command for creating a new stack (`mack init`) as baseline from the current system or from template or from a mixture where the template is only used for components that cannot be retrieved from- or are not present in the current system
	* If necessary, add reasonable example stack or illustrative stack template
- [ ] [Setup default SSH key](documentation/MacStack/feature_plans/ssh/) (for GitHub, GitLab etc.)
- [ ] System (and app-) settings (likely via Ansible? App settings via [mackup](https://github.com/lra/mackup)?)
- [ ] Review whether we should rather use mise for managing dev tools that require further version management and benefit from mise features. Apparently mise also offers some declarative capabilities for global tool managament (~/.config/mise/mise.toml ...)
- [ ] explore idea of a "macstack registry" where people can register and browse and copy stacks, also any personal stack definition could be anchored in a registry stack (point to that) as the baseline default, and the personal stack itself would only define overrides, similar to how user settings in an IDE override some things but use the defaults otherwise ...
- [ ] Feature requests:
	* integrate repo based password management


## Done





%% kanban:settings
```
{"kanban-plugin":"board","list-collapse":[false,false,true],"show-checkboxes":false,"new-card-insertion-method":"prepend","full-list-lane-width":true,"show-relative-date":true,"lane-width":500,"tag-colors":[{"tagKey":"#bug","color":"rgba(255, 255, 255, 1)","backgroundColor":"rgba(183, 0, 0, 1)"}]}
```
%%