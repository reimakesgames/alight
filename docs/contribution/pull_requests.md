# Pull Requests
If you want to merge your changes, you can do so by creating a pull request on GitHub.

Follow the instructions below to create a pull request.

!!! Warning
	You are not allowed to merge your own pull requests.
	You must have at least one other person review your code before it can be merged.

!!! Note
	You are advised to keep your pull requests small and concise, so that they can be reviewed and merged quickly and not affect other contributors.

---

## Pull Request Structure
### Feature Branches
#### Name
Your Pull Request name should be formatted as `[type] [issue_number(s)] short description here`.
Example:
```
bug 1 removed unnecessary code
feature 2 added new feature
feature 7 enabled foo bar
bug 8 fixed foo bar
bug 12, 13 fixed foo bar
feature 14-16 added new feature
```

#### Description
The Pull Request description should be formatted as follows:
```md
This PR fixes #1 and #2.
It also adds a new feature, which is described in #3.
```

---

### Working to Main
!!! Note
	You as a contributer don't need to worry about this.
	This is for the maintainers of the project.
#### Name
The Pull Request name should be formatted as `X.Y.Z`.
Example:
```
1.0.0
1.0.1
1.1.0
```

#### Description
The Pull Request description should be formatted as follows:
```md
# [X.Y.Z] - YYYY-MM-DD
### Added
- New Foo destructor CLOSES #1
- New Bar destructor CLOSES #2
### Changed
- Changed FooBar to FooBar2 CLOSES #3
### Fixed
- Fixed FooBar CLOSES #4
```

`CLOSES #1` is important, as it will automatically close the issue when the PR is merged.
This does not work for Feature Branches PRs though.

For more information, see [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).
TL;DR: Keep a Changelog is a changelog format that is designed to be easy to read and understand.

---

## FAQ
#### Working on a large feature?
Create a pull request for each part of the feature.
#### Working on a small bug fix?
Create a pull request for each bug fix.
