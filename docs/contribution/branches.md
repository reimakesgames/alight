# Branches

## Feature Branches
In feature branches, you should be working on a specific feature or bug fix.
You should create a new branch for each feature or bug fix you are working on.

### Name
Your branch name should be formatted as `feature/[#issue_number]-short-description-here`.

Example:
```
feature/1-implement-foo
feature/2-implement-bar
feature/3-implement-foo-bar
```

!!! note
	I personally do these individually, but you can do multiple issues in one branch.
	For example, you could do `feature/1-3-implement-foo-bar-baz`.
	Or for a longer example, `feature/1-3-5-7-9-implement-foo-bar-baz-qux-quux-corge-grault-garply`.

### Description
The branch description should be formatted as follows:
```md
This branch implements #1

The code is generic, as it could be used for other features.
currently, it is only used for feature #1.
```

## Bug Branches
It is similar to a feature branch, but you should use the `bug` prefix instead of `feature`.

!!! Note
	You should only create a bug branch if there is an issue for the bug.
	If there is no issue, create one first.
