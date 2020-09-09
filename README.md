# git_helper [![Maintainability](https://api.codeclimate.com/v1/badges/ce1bdd719cc21b7c22a6/maintainability)](https://codeclimate.com/github/emmasax4/git_helper/maintainability)

## Usage

```bash
gem install git_helper
```

Some of the commands in this gem can be used without any additional configuration. However, others utilize special GitHub or GitLab configuration. To provide access tokens for this, create a `~/.git_config.yml` file. The contents should look like this:

```
:github_user: GITHUB-USERNAME
:github_token: GITHUB-TOKEN
:gitlab_user: GITLAB-USERNAME
:gitlab_token: GITLAB-TOKEN
```

To view the help screen, run:
```bash
ghelper --help
```

To see what version of git_helper you're running, run:
```bash
ghelper --version
```

## Commands

### `change-remote`

This can be used when switching the owners of a GitHub repo. When you switch a username, GitHub only makes some changes for you. With this command, you no longer have to manually walk through local repo and switch the remotes from each one into a remote with the new username.

This command will go through every directory in a directory, see if it is a git directory, and then will check to see if the old username is included in the remote URL of that git directory. If it is, then the command will change the remote URL to instead point to the new username's remote URL. To run the command, run:

```
ghelper change-remote OLD-OWNER NEW-OWNER
```

### `checkout-default`

This command will check out the default branch of whatever repository you're currently in. It looks at what branch the `origin/HEAD` remote is pointed to on your local machine, versus querying GitHub/GitLab for that, so if your local machine's remotes aren't up to date, then this command won't work as expected. To run this command, run:

```
ghelper checkout-default
```

If your local branches aren't right (run `git branch --remote` to see), then run:

```
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/CORRECT-DEFAULT-BRANCH-GOES-HERE
```

### `clean-git`

This command will bring you to the repository's default branch, `git pull`, `git fetch -p`, and will clean up your local branches on your machine by seeing which ones are existing on the remote, and updating yours accordingly. To run:

```
ghelper clean-git
```

### `empty-commit`

For some reason, I'm always forgetting the commands to create an empty commit. So with this command, it becomes easy. The commit message of this commit will be `'Empty commit'`. To run the command, run:

```
ghelper empty-commit
```

### `new-branch`

This command is useful for making new branches in a repository on the command line. To run the command, run:

```
ghelper new-branch
# OR
ghelper new-branch NEW_BRANCH_NAME
```

The command either accepts a branch name right away or it will ask you for the name of your new branch. Make sure your input does not contain any spaces or special characters.

### `pull-request`

This command can be used to handily make new GitHub pull requests and to merge pull requests from the command line. The command uses the [`Octokit::Client`](https://octokit.github.io/octokit.rb/Octokit/Client.html) to do this, so make sure you have a `.git_config.yml` file set up in the home directory of your computer. For instructions on how to do that, see [Usage](#usage).

After setup is complete, you can call the file, and send in a flag indicating whether to create a pull request, `-c`, or to merge a pull request, `-m`.

```
ghelper pull-request -c
# OR
ghelper pull-request -m
```

If you're trying to create a pull request, the command will provide an autogenerated pull request title based on your branch name (separated by `_`). You can respond 'yes' or 'no'. If you respond 'no', you can provide your own pull request title. The command will also ask you if the default branch of the repository is the proper base branch to use. You can say 'yes' or 'no'. If you respond 'no', then you can give the command your chosen base base. Lastly, it'll ask the user to apply any pull request templates found at any `*/pull_request_template.md` file or any file in `.github/PULL_REQUEST_TEMPLATE/*.md`. Applying any template is optional, and a user can make an empty pull request if they desire.

If you're requesting to merge a pull request, the command will ask you the number ID of the pull request you wish to merge. The command will also ask you what type of merge to do: regular merging, squashing, or rebasing. The commit message to use during the merge/squash/rebase will be the title of the pull request.

If you're getting stuck, you can run the command with a `--help` flag instead, to get some more information.

### `merge-request`

This command can be used to handily make new GitLab merge requests and to accept merge requests from the command line. The command uses the Ruby wrapper [`Gitlab`](https://github.com/NARKOZ/gitlab) to do this, so make sure you have a `.git_config.yml` file set up in the home directory of your computer. For instructions on how to do that, see [Usage](#usage).

After setup is complete, you can call the file, and send in a flag indicating whether to create a pull request, `-c`, or to merge a pull request, `-m`.

```
ghelper merge-request -c
# OR
ghelper merge-request -m
```

If you're trying to create a merge request, the command will provide an autogenerated merge request title based on your branch name (separated by `_`). You can respond 'yes' or 'no'. If you respond 'no', you can provide your own merge request title. The command will also ask you if the default branch of the repository is the proper base branch to use. You can say 'yes' or 'no'. If you respond 'no', then you can give the command your chosen base base. Lastly, it'll ask the user to apply any merge request templates found at any `*/merge_request_template.md` file or any file in `.gitlab/merge_request_templates/*.md`. Applying any template is optional, and from the command's standpoint, a user can make an empty merge request if they desire. If a GitLab project automatically adds a template, then it may create a merge request with a default template anyway.

If you're requesting to merge a merge request, the command will ask you the number ID of the merge request you wish to accept. The command will also ask you what type of merge to do: regular merging or squashing. The commit message to use during the merge/squash will be the title of the pull request.

If you're getting stuck, you can run the command with a `--help` flag instead, to get some more information.

## Contributing

To submit a feature request, bug ticket, etc, please submit an official [GitHub Issue](https://github.com/emmasax4/git_helper/issues/new).

To report any security vulnerabilities, please view this project's [Security Policy](https://github.com/emmasax4/git_helper/security/policy).

This repository does have a standard [Code of Conduct](https://github.com/emmasax4/git_helper/blob/main/.github/code_of_conduct.md).
