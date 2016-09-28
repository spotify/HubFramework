# Mainly to encourage writing up some reasoning about the PR, rather than just leaving a title
if github.pr_body.length < 5
  fail "Please provide a summary in the Pull Request description"
end

# Just to let people know
warn("PR is classed as Work in Progress") if github.pr_title.include? "[WIP]"

# Make a note about contributors not in the organization
unless github.api.organization_member?('spotify', github.pr_author)
  # Pay extra attention if external contributors modify certain files
  if git.modified_files.include?("Gemfile") or git.modified_files.include?("Gemfile.lock")
    warn "External contributor has edited the Gemfile and/or Gemfile.lock"
  end
  if git.modified_files.include?("HubFramework.podspec")
    warn "External contributor has edited the HubFramework.podspec"
  end
end

# Fail if the project.xcconfig file is modified since that’s not supported.
if git.modified_files.include?("project.xcconfig")
	fail "The project.xcconfig must not be modified, please change spotify_os.xcconfig instead"
end

# Give inline test fail reports
junit.parse "build/tests/report.junit"
junit.report
