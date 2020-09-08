#!/usr/bin/env ruby

require_relative './octokit_client.rb'
require_relative './highline_cli.rb'

class GitHubPullRequest
  def create
    begin
      # Ask these questions right away
      base_branch
      new_pr_title
      new_pr_body

      puts "Creating pull request: #{new_pr_title}"
      pr = octokit_client.create_pull_request(local_repo, base_branch, local_branch, new_pr_title, new_pr_body)
      puts "Pull request successfully created: #{pr.html_url}"
    rescue Octokit::UnprocessableEntity => e
      puts 'Could not create pull request:'
      if e.message.include?('pull request already exists')
        puts '  A pull request already exists for this branch'
      elsif e.message.include?('No commits between')
        puts '  No commits have been pushed to GitHub'
      else
        puts e.message
      end
    rescue Exception => e
      puts 'Could not create pull request:'
      puts e.message
    end
  end

  def merge
    begin
      # Ask these questions right away
      pr_id
      merge_method

      puts "Merging pull request: #{pr_id}"
      merge = octokit_client.merge_pull_request(local_repo, pr_id, existing_pr_title, { merge_method: merge_method })
      puts "Pull request successfully merged: #{merge.sha}"
    rescue Octokit::UnprocessableEntity => e
      puts 'Could not merge pull request:'
      puts e.message
    rescue Octokit::NotFound => e
      puts 'Could not merge pull request:'
      puts "  Could not a locate a pull request to merge with ID #{pr_id}"
    rescue Octokit::MethodNotAllowed => e
      puts 'Could not merge pull request:'
      if e.message.include?('405 - Required status check')
        puts '  A required status check has not passed'
      elsif e.message.include?('405 - Base branch was modified')
        puts '  The base branch has been modified'
      elsif e.message.include?('405 - Pull Request is not mergeable')
        puts '  The pull request is not mergeable'
      elsif e.message.include?('405 - Rebase merges are not allowed on this repository')
        puts '  Rebase merges are not allowed on this repository'
      elsif e.message.include?('405 - Merge commits are not allowed on this repository')
        puts '  Merge commits are not allowed on this repository'
      elsif e.message.include?('405 - Squash commits are not allowed on this repository')
        puts '  Squash merges are not allowed on this repository'
      else
        puts e.message
      end
    rescue Exception => e
      puts 'Could not merge pull request:'
      puts e.message
    end
  end

  private def local_repo
    # Get the repository by looking in the remote URLs for the full repository name
    remotes = `git remote -v`
    return remotes.scan(/\S[\s]*[\S]+.com[\S]{1}([\S]*).git/).first.first
  end

  private def local_branch
    # Get the current branch by looking in the list of branches for the *
    branches = `git branch`
    return branches.scan(/\*\s([\S]*)/).first.first
  end

  private def read_template
    if pr_template_options.count == 1
      apply_template?(pr_template_options.first) ? File.open(pr_template_options.first).read : ''
    else
      template_file_name_to_apply = template_to_apply
      template_file_name_to_apply == "None" ? '' : File.open(template_file_name_to_apply).read
    end
  end

  private def merge_options
    [ 'merge', 'squash', 'rebase' ]
  end

  private def pr_id
    @pr_id ||= cli.ask('Pull Request ID?')
  end

  private def existing_pr_title
    @existing_pr_title ||= octokit_client.pull_request(local_repo, pr_id).title
  end

  private def new_pr_title
    @new_pr_title ||= accept_autogenerated_title? ? autogenerated_title : cli.ask('Title?')
  end

  private def new_pr_body
    @new_pr_body ||= pr_template_options.empty? ? '' : read_template
  end

  private def base_branch
    @base_branch ||= base_branch_default? ? default_branch : cli.ask('Base branch?')
  end

  private def autogenerated_title
    @autogenerated_title ||= local_branch.split('_')[0..-1].join(' ').capitalize
  end

  private def default_branch
    @default_branch ||= octokit_client.repository(local_repo).default_branch
  end

  private def merge_method
    return @merge_method if @merge_method
    index = cli.ask_options("Merge method?", merge_options)
    @merge_method = merge_options[index]
  end

  private def pr_template_options
    return @pr_template_options if @pr_template_options
    nested_templates = Dir.glob(File.join("**/PULL_REQUEST_TEMPLATE", "*.md"), File::FNM_DOTMATCH | File::FNM_CASEFOLD)
    non_nested_templates = Dir.glob(File.join("**", "pull_request_template.md"), File::FNM_DOTMATCH | File::FNM_CASEFOLD)
    @pr_template_options = nested_templates.concat(non_nested_templates)
  end

  private def base_branch_default?
    answer = cli.ask("Is '#{default_branch}' the correct base branch for your new pull request? (y/n)")
    !!(answer =~ /^y/i)
  end

  private def accept_autogenerated_title?
    answer = cli.ask("Accept the autogenerated pull request title '#{autogenerated_title}'? (y/n)")
    !!(answer =~ /^y/i)
  end

  private def apply_template?(template_file_name)
    answer = cli.ask("Apply the pull request template from #{template_file_name}? (y/n)")
    !!(answer =~ /^y/i)
  end

  private def template_to_apply
    return @template_to_apply if @template_to_apply
    complete_options = pr_template_options << 'None'
    index = cli.ask_options("Which pull request template should be applied?", complete_options)
    @template_to_apply = complete_options[index]
  end

  private def octokit_client
    @octokit_client ||= OctokitClient.new.client
  end

  private def cli
    @cli ||= HighlineCli.new
  end
end

arg = ARGV[0]

case arg
when '-c', '--create'
  action = :create
when '-m', '--merge'
  action = :merge
when '-h', '--help', nil, ''
  puts """
Usage for working with this pull requests script:
  # Run this script from within your local repository/branch
  ./pull_request.rb [-h|-c|-m]

  -h, --help      - Displays this help information
  -c, --create    - Create a new pull request
  -m, --merge     - Merge an existing pull request

Required: create or merge
Examples:
  ./pull_request.rb -c
  ./pull_request.rb -m
    """
    exit(0)
end

pull_request = GitHubPullRequest.new

case action
when :create
  pull_request.create
when :merge
  pull_request.merge
end
