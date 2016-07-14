#!/bin/bash

set -e +o pipefail

VERSION="113a5a7"

url="https://codecov.spotify.net"
url_o=""
verbose="0"
env="$CODECOV_ENV"
pr_o=""
pr=""
job=""
build_url=""
service=""
build_o=""
token=""
commit_o=""
search_in=""
tag_o=""
tag=""
flags=""
exit_with=0
branch_o=""
slug_o=""
dump="0"
branch=""
commit=""
ddp="$(echo ~)/Library/Developer/Xcode/DerivedData"
xp=""
files=""
cacert="$CODECOV_CA_BUNDLE"
gcov_ignore=""
ft_gcov="1"
ft_coveragepy="1"
ft_fix="1"
_git_root=$(git rev-parse --show-toplevel 2>/dev/null || hg root 2>/dev/null || echo $PWD)
git_root="$_git_root"
if [ "$git_root" = "$PWD" ];
then
  git_root="."
fi

proj_root="$git_root"
gcov_exe="gcov"
gcov_arg=""

b="\033[0;36m"
g="\033[0;32m"
r="\033[0;31m"
e="\033[0;90m"
x="\033[0m"

show_help() {
cat << EOF
Codecov $VERSION
Upload reports to Codecov

    -h           Display this help and exit
    -f COVERAGE  Reference a specific file only to upload
                 When not specified commonly known coverage files will found
    -s DIR       Directory to search for coverage reports.
                 Already searches project root and artifact folders.
    -t TOKEN     Set the private repository token
                 (or) set environment variable CODECOV_TOKEN=:uuid
    -e ENV       Specify environment variables to be included with this build
                 ex. codecov -e VAR,VAR2
                 (or) set environment variable CODECOV_ENV=VAR,VAR2
    -X feature   Toggle functionalities, accepting: 'gcov', 'coveragepy', 'nocolor', 'fix'
    -R root dir  Used when not in git/hg project to identify project root directory
    -F flag      Flag this upload to with one or more titles
                 ex. -F unittests -F docker
    -K           Remove color from the output
    -Z           Exit with 1 if not successful. Default will Exit with 0

    -- Override CI Environment Variables --
       These variables are automatically detected by popular CI providers
    -B branch    Specify the branch name
    -C sha       Specify the commit sha
    -P pr        Specify the pull request number
    -b build     Specify the build number
    -T tag       Specify the git tag

    -- xcode --
    -D           Custom Derived Data Path for Coverage.profdata and gcov processing
                 Default '~/Library/Developer/Xcode/DerivedData'
    -J           Specify packages to build coverage.
                 This *significantly* reduces time to build coverage reports.
                 Ex. -J 'MyAppName'

    -- gcov --
    -g GLOB      Paths to ignore during gcov gathering
    -p dir       Project root directory (default: PWD, WORKSPACE, or TRAVIS_BUILD_DIR)
                 Also used when preparing gcov
    -x gcovexe   gcov executable to run. Defaults to 'gcov'
    -a gcovargs  extra arguments to pass to gcov

    -- Enterprise customers --
    -u URL       Set the target url for Enterprise customers [default https://codecov.io]
                 (or) set environment variable CODECOV_URL=https://my-hosted-codecov.com
    -r           owner/repo slug used instead of the private repo token in Enterprise
                 (or) set environment variable CODECOV_SLUG=:owner/:repo
    -S           File path to your cacert.pem file used to verify ssl with Codecov Enterprise (optional)
                 Detected in environment variable: CODECOV_CA_BUNDLE

    -- Debugging --
    -v           Verbose Mode
    -d           Dont upload and dump to stdin

Contribute and source at https://github.com/codecov/codecov-bash
EOF
}

say() {
  echo -e "$1"
}


urlencode() {
  echo "$1" | curl -Gso /dev/null -w %{url_effective} --data-urlencode @- "" | cut -c 3- | sed -e 's/%0A//'
}


swiftcov() {
  _dir=$(dirname "$1")
  for _type in app framework xctest
  do
    find "$_dir" -name "*.$_type" | while read f
    do
      _proj=${f##*/}
      _proj=${_proj%."$_type"}
      if [ "$2" = "" ] || [ "$(echo "$_proj" | grep -i "$2")" != "" ];
      then
        say "    $g+$x Building reports for $_proj $_type"
        _proj_name=$(echo "$_proj" | sed -e 's/[[:space:]]//g')
        xcrun llvm-cov show -instr-profile "$1" "$f/$_proj" > "$_proj_name.$_type.coverage.txt" \
         || say "    ${r}x>${x} llvm-cov failed to produce results for $f/$_proj"
      fi
    done
  done
}


# Credits to: https://gist.github.com/pkuczynski/8665367
parse_yaml() {
   local prefix=$2
   local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
   sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
        -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p" $1 |
   awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
         vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
         printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
   }'
}

if [ $# != 0 ];
then
  while getopts "svdhu:t:f:r:e:g:p:s:T:X:x:a:b:C:B:P:D:S:R:J:F:K:Z" o
  do
    case "$o" in
      "v")
        verbose="1"
        ;;
      "K")
        b=""
        g=""
        r=""
        e=""
        x=""
        ;;
      "s")
        if [ "$search_in" = "" ];
        then
          search_in="$OPTARG"
        else
          search_in="$search_in $OPTARG"
        fi
        ;;
      "T")
        tag_o="$OPTARG"
        ;;
      "d")
        dump="1"
        ;;
      "C")
        commit_o="$OPTARG"
        ;;
      "D")
        ddp="$OPTARG"
        ;;
      "B")
        branch_o="$OPTARG"
        ;;
      "P")
        pr_o="$OPTARG"
        ;;
      "S")
        cacert="--cacert \"$OPTARG\""
        ;;
      "R")
        git_root="$OPTARG"
        ;;
      "b")
        build_o="$OPTARG"
        ;;
      "h")
        show_help
        exit 0;
        ;;
      "u")
        url_o=$(echo "$OPTARG" | sed -e 's/\/$//')
        ;;
      "t")
        token="$OPTARG"
        ;;
      "f")
        if [ "$files" = "" ];
        then
          files="$OPTARG"
        else
          files="$files
$OPTARG"
        fi
        ;;
      "F")
        if [ "$flags" = "" ];
        then
          flags="$OPTARG"
        else
          flags="$flags,$OPTARG"
        fi
        ;;
      "J")
        if [ "$xp" = "" ];
        then
          xp="$OPTARG"
        else
          xp="$xp\|$OPTARG"
        fi
        ;;
      "p")
        proj_root="$OPTARG"
        ;;
      "r")
        slug_o="$OPTARG"
        ;;
      "X")
        if [ "$OPTARG" = "gcov" ];
        then
          ft_gcov="0"
        elif [ "$OPTARG" = "coveragepy" ];
        then
          ft_coveragepy="0"
        elif [ "$OPTARG" = "fix" ];
        then
          ft_fix="0"
        elif [ "$OPTARG" = "nocolor" ];
        then
          b=""
          g=""
          r=""
          e=""
          x=""
        fi
        ;;
      "g")
        gcov_ignore="$gcov_ignore -not -path '$OPTARG'"
        ;;
      "x")
        gcov_exe=$OPTARG
        ;;
      "a")
        gcov_arg=$OPTARG
        ;;
      "e")
        env="$env,$OPTARG"
        ;;
      "Z")
        exit_with=1
        ;;
    esac
  done
fi

say "
  _____          _
 / ____|        | |
| |     ___   __| | ___  ___ _____   __
| |    / _ \\ / _\` |/ _ \\/ __/ _ \\ \\ / /
| |___| (_) | (_| |  __/ (_| (_) \\ V /
 \\_____\\___/ \\__,_|\\___|\\___\\___/ \\_/
                                $VERSION

"

if [ "$JENKINS_URL" != "" ];
then
  say "$e==>$x Jenkins CI detected."
  # https://wiki.jenkins-ci.org/display/JENKINS/Building+a+software+project
  # https://wiki.jenkins-ci.org/display/JENKINS/GitHub+pull+request+builder+plugin#GitHubpullrequestbuilderplugin-EnvironmentVariables
  service="jenkins"
  branch=$([ ! -z "$ghprbSourceBranch" ] && echo "$ghprbSourceBranch" || echo "$GIT_BRANCH")
  commit=$([ ! -z "$ghprbActualCommit" ] && echo "$ghprbActualCommit" || echo "$GIT_COMMIT")
  build="$BUILD_NUMBER"
  pr="$ghprbPullId"
  build_url=$(urlencode "$BUILD_URL")

elif [ "$CI" = "true" ] && [ "$TRAVIS" = "true" ] && [ "$SHIPPABLE" != "true" ];
then
  say "$e==>$x Travis CI detected."
  # http://docs.travis-ci.com/user/ci-environment/#Environment-variables
  service="travis"
  branch="$TRAVIS_BRANCH"
  commit="$TRAVIS_COMMIT"
  build="$TRAVIS_JOB_NUMBER"
  pr="$TRAVIS_PULL_REQUEST"
  job="$TRAVIS_JOB_ID"
  slug="$TRAVIS_REPO_SLUG"
  tag="$TRAVIS_TAG"

elif [ "$CI" = "true" ] && [ "$CI_NAME" = "codeship" ];
then
  say "$e==>$x Codeship CI detected."
  # https://www.codeship.io/documentation/continuous-integration/set-environment-variables/
  service="codeship"
  branch="$CI_BRANCH"
  build="$CI_BUILD_NUMBER"
  build_url=$(urlencode "$CI_BUILD_URL")
  commit="$CI_COMMIT_ID"

elif [ "$TEAMCITY_VERSION" != "" ];
then
  say "$e==>$x TeamCity CI detected."
  # https://confluence.jetbrains.com/display/TCD8/Predefined+Build+Parameters
  # https://confluence.jetbrains.com/plugins/servlet/mobile#content/view/74847298
  if [ "$TEAMCITY_BUILD_BRANCH" = '' ];
  then
    echo "    Teamcity does not automatically make build parameters available as environment variables."
    echo "    Add the following environment parameters to the build configuration"
    echo "    env.TEAMCITY_BUILD_BRANCH = %teamcity.build.branch%"
    echo "    env.TEAMCITY_BUILD_ID = %teamcity.build.id%"
    echo "    env.TEAMCITY_BUILD_URL = %teamcity.serverUrl%/viewLog.html?buildId=%teamcity.build.id%"
    echo "    env.TEAMCITY_BUILD_COMMIT = %system.build.vcs.number%"
    echo "    env.TEAMCITY_BUILD_REPOSITORY = %vcsroot.<YOUR TEAMCITY VCS NAME>.url%"
  fi
  service="teamcity"
  branch="$TEAMCITY_BUILD_BRANCH"
  build="$TEAMCITY_BUILD_ID"
  build_url=$(urlencode "$TEAMCITY_BUILD_URL")
  if [ "$TEAMCITY_BUILD_COMMIT" = "" ];
  then
    commit="$TEAMCITY_BUILD_COMMIT"
  else
    commit="$BUILD_VCS_NUMBER"
  fi
  slug=$(echo "$TEAMCITY_BUILD_REPOSITORY" | cut -d'/' -f4-5 | sed -e 's/\.git//')

elif [ "$CI" = "true" ] && [ "$CIRCLECI" = "true" ];
then
  say "$e==>$x Circle CI detected."
  # https://circleci.com/docs/environment-variables
  service="circleci"
  branch="$CIRCLE_BRANCH"
  build="$CIRCLE_BUILD_NUM.$CIRCLE_NODE_INDEX"
  slug="$CIRCLE_PROJECT_USERNAME/$CIRCLE_PROJECT_REPONAME"
  pr="$CIRCLE_PR_NUMBER"
  commit="$CIRCLE_SHA1"
  search_in="$search_in $CIRCLE_ARTIFACTS"

elif [ "$CI" = "true" ] && [ "$BITRISE_IO" = "true" ];
then
  say "$e==>$x Bitrise CI detected."
  service="bitrise"
  branch="$BITRISE_GIT_BRANCH"
  build="$BITRISE_BUILD_NUMBER"
  build_url=$(urlencode "$BITRISE_BUILD_URL")
  pr="$BITRISE_PULL_REQUEST"
  commit=$([ "$BITRISE_GIT_COMMIT" != "" ] && echo "$BITRISE_GIT_COMMIT" || echo $(git rev-parse HEAD 2>/dev/null || hg id -i --debug 2>/dev/null | tr -d '+'))

elif [ "$CI" = "true" ] && [ "$SEMAPHORE" = "true" ];
then
  say "$e==>$x Semaphore CI detected."
  # https://semaphoreapp.com/docs/available-environment-variables.html
  service="semaphore"
  branch="$BRANCH_NAME"
  build="$SEMAPHORE_BUILD_NUMBER.$SEMAPHORE_CURRENT_THREAD"
  pr="$PULL_REQUEST_NUMBER"
  slug="$SEMAPHORE_REPO_SLUG"
  commit="$REVISION"
  env="$env,$SEMAPHORE_TRIGGER_SOURCE"

elif [ "$CI" = "true" ] && [ "$BUILDKITE" = "true" ];
then
  say "$e==>$x Buildkite CI detected."
  # https://buildkite.com/docs/guides/environment-variables
  service="buildkite"
  branch="$BUILDKITE_BRANCH"
  build="$BUILDKITE_BUILD_NUMBER.$BUILDKITE_JOB_ID"
  build_url=$(urlencode "$BUILDKITE_BUILD_URL")
  slug="$BUILDKITE_PROJECT_SLUG"
  commit="$BUILDKITE_COMMIT"

elif [ "$CI" = "true" ] && [ "$DRONE" = "true" ];
then
  say "$e==>$x Drone CI detected."
  # http://docs.drone.io/env.html
  # drone commits are not full shas
  service="drone.io"
  branch="$DRONE_BRANCH"
  build="$DRONE_BUILD_NUMBER"
  build_url=$(urlencode "$DRONE_BUILD_URL")
  commit=$(git rev-parse HEAD 2>/dev/null || hg id -i --debug 2>/dev/null | tr -d '+')

elif [ "$CI" = "True" ] && [ "$APPVEYOR" = "True" ];
then
  say "$e==>$x Appveyor CI detected."
  # http://www.appveyor.com/docs/environment-variables
  service="appveyor"
  branch="$APPVEYOR_REPO_BRANCH"
  build=$(urlencode "$APPVEYOR_JOB_ID")
  pr="$APPVEYOR_PULL_REQUEST_NUMBER"
  job="$APPVEYOR_ACCOUNT_NAME%2F$APPVEYOR_PROJECT_SLUG%2F$APPVEYOR_BUILD_VERSION"
  slug="$APPVEYOR_REPO_NAME"
  commit="$APPVEYOR_REPO_COMMIT"

elif [ "$CI" = "true" ] && [ "$WERCKER_GIT_BRANCH" != "" ];
then
  say "$e==>$x Wercker CI detected."
  # http://devcenter.wercker.com/articles/steps/variables.html
  service="wercker"
  branch="$WERCKER_GIT_BRANCH"
  build="$WERCKER_MAIN_PIPELINE_STARTED"
  slug="$WERCKER_GIT_OWNER/$WERCKER_GIT_REPOSITORY"
  commit="$WERCKER_GIT_COMMIT"

elif [ "$CI" = "true" ] && [ "$MAGNUM" = "true" ];
then
  say "$e==>$x Magnum CI detected."
  # https://magnum-ci.com/docs/environment
  service="magnum"
  branch="$CI_BRANCH"
  build="$CI_BUILD_NUMBER"
  commit="$CI_COMMIT"

elif [ "$CI" = "true" ] && [ "$SNAP_CI" = "true" ];
then
  say "$e==>$x Snap CI detected."
  # https://docs.snap-ci.com/environment-variables/
  service="snap"
  branch=$([ "$SNAP_BRANCH" != "" ] && echo "$SNAP_BRANCH" || echo "$SNAP_UPSTREAM_BRANCH")
  build="$SNAP_PIPELINE_COUNTER"
  job="$SNAP_STAGE_NAME"
  pr="$SNAP_PULL_REQUEST_NUMBER"
  commit=$([ "$SNAP_COMMIT" != "" ] && echo "$SNAP_COMMIT" || echo "$SNAP_UPSTREAM_COMMIT")
  env="$env,DISPLAY"

elif [ "$SHIPPABLE" = "true" ];
then
  say "$e==>$x Shippable CI detected."
  # http://docs.shippable.com/ci_configure/
  service="shippable"
  branch="$BRANCH"
  build="$BUILD_NUMBER"
  build_url=$(urlencode "$BUILD_URL")
  pr="$PULL_REQUEST"
  slug="$REPO_FULL_NAME"
  commit="$COMMIT"

elif [ "$GREENHOUSE" = "true" ];
then
  say "$e==>$x Greenhouse CI detected."
  # http://docs.greenhouseci.com/docs/environment-variables-files
  service="greenhouse"
  branch="$GREENHOUSE_BRANCH"
  build="$GREENHOUSE_BUILD_NUMBER"
  build_url=$(urlencode "$GREENHOUSE_BUILD_URL")
  pr="$GREENHOUSE_PULL_REQUEST"
  commit="$GREENHOUSE_COMMIT"
  search_in="$search_in $GREENHOUSE_EXPORT_DIR"

elif [ "$CI_SERVER_NAME" = "GitLab CI" ];
then
  say "$e==>$x GitLab CI detected."
  # http://doc.gitlab.com/ce/ci/variables/README.html
  service="gitlab"
  branch="$CI_BUILD_REF_NAME"
  build="$CI_BUILD_ID"
  slug=$(echo "$CI_BUILD_REPO" | cut -d'/' -f4-5 | sed -e 's/\.git//')
  commit="$CI_BUILD_REF"

else
  say "${r}x>${x} No CI provider detected."

  commit="$VCS_COMMIT_ID"
  branch="$VCS_BRANCH_NAME"
  pr="$VCS_PULL_REQUEST"
  slug="$VCS_SLUG"
  build_url="$CI_BUILD_URL"
  build="$CI_BUILD_ID"

fi

say "    ${e}project root:${x} $git_root"

# find branch, commit, repo from git command
if [ "$GIT_BRANCH" != "" ];
then
  branch="$GIT_BRANCH"

elif [ "$branch" = "" ];
then
  branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || hg branch 2>/dev/null || echo "")
  if [ "$branch" = "HEAD" ]; then branch=""; fi
fi

if [ "$commit_o" = "" ];
then
  # merge commit -> actual commit
  mc=$(git log -1 --pretty=%B 2>/dev/null | tr -d '[[:space:]]' || true)
  if [[ "$mc" =~ ^Merge[[:space:]][a-z0-9]{40}[[:space:]]into[[:space:]][a-z0-9]{40}$ ]];
  then
    # Merge xxx into yyy
    say "    Fixing merge commit sha"
    commit=$(echo "$mc" | cut -d' ' -f2)
  elif [ "$GIT_COMMIT" != "" ];
  then
    commit="$GIT_COMMIT"
  elif [ "$commit" = "" ];
  then
    commit=$(git rev-parse HEAD 2>/dev/null || hg id -i --debug 2>/dev/null | tr -d '+' || echo "")
  fi
else
  commit="$commit_o"
fi

if [ "$CODECOV_TOKEN" != "" ] && [ "$token" = "" ];
then
  say "${e}-->${x} token set from env"
  token="$CODECOV_TOKEN"
fi

if [ "$CODECOV_URL" != "" ] && [ "$url_o" = "" ];
then
  say "${e}-->${x} url set from env"
  url_o=$(echo "$CODECOV_URL" | sed -e 's/\/$//')
fi

if [ "$CODECOV_SLUG" != "" ];
then
  say "${e}-->${x} slug set from env"
  slug_o="$CODECOV_SLUG"
fi


yaml=$(find "$proj_root" -name 'codecov.yml' -or -name '.codecov.yml' | head -1 | sed -e 's/^\.\///')

if [ "$yaml" != "" ];
then
  eval $(parse_yaml "$yaml" "yml_" || true)

  if [ "$yml_codecov_token" != "" ] && [ "$token" = "" ];
  then
    say "${e}-->${x} token set from yaml"
    token="$yml_codecov_token"
  fi

  if [ "$yml_codecov_url" != "" ] && [ "$url_o" = "" ];
  then
    say "${e}-->${x} url set from yaml"
    url_o="$yml_codecov_url"
  fi

  if [ "$yml_codecov_slug" != "" ] && [ "$slug_o" = "" ];
  then
    say "${e}-->${x} slug set from yaml"
    slug_o="$yml_codecov_slug"
  fi

fi

if [ "$branch_o" != "" ];
then
  branch=$(urlencode "$branch_o")
else
  branch=$(urlencode "$branch")
fi

query="branch=$branch\
       &commit=$commit\
       &build=$([ "$build_o" = "" ] && echo "$build" || echo "$build_o")\
       &build_url=$build_url\
       &tag=$([ "$tag_o" = "" ] && echo "$tag" || echo "$tag_o")\
       &slug=$([ "$slug_o" = "" ] && echo "$slug" || echo "$slug_o")\
       &yaml=$(urlencode "$yaml")\
       &service=$service\
       &flags=$flags\
       &pr=$([ "$pr_o" = "" ] && echo "$pr" || echo "$pr_o")\
       &job=$job"

# detect bower comoponents location
bower_components="bower_components"
bower_rc=$(cd "$git_root" && cat .bowerrc 2>/dev/null || echo "")
if [ "$bower_rc" != "" ];
then
  bower_components=$(echo "$bower_rc" | tr -d '\n' | grep '"directory"' | cut -d'"' -f4 | sed -e 's/\/$//')
  if [ "$bower_components" = "" ];
  then
    bower_components="bower_components"
  fi
fi

# find all the reports
if [ "$files" != "" ];
then
  say "$e==>$x Targeting specific file(s)"

else

  if [ -d "$ddp" ];
  then
    say "${e}==>${x} Swift in $ddp"

    # xcode via profdata
    if [ "$xp" = "" ];
    then
      # xp=$(xcodebuild -showBuildSettings 2>/dev/null | grep -i "^\s*PRODUCT_NAME" | sed -e 's/.*= \(.*\)/\1/')
      # say " ${e}->${x} Speed up XCode processing by adding ${e}-J '$xp'${x}"
      say "    ${e}->${x} Speed up xcode processing by using use -J 'AppName'"
    fi

    while read -r profdata;
    do
      swiftcov "$profdata" "$xp"
    done <<< "$(find "$ddp" -name '*.profdata')"
  fi

  if [ "$ft_gcov" = "1" ];
  then
    say "${e}==>${x} Running gcov ${e}disable via -X gcov${x}"
    # search for osx coverage data
    if [ -d "$ddp" ];
    then
      say "    ${e}->${x} Obj-C in $ddp"
      find "$ddp" -name '*.gcda' -exec gcov -pbcu {} + || true
    fi

    # all other gcov
    say "    ${e}->${x} Running $gcov_exe in $proj_root"
    bash -c "find $proj_root -type f -name '*.gcno' $gcov_ignore -exec $gcov_exe -pb $gcov_arg {} +" || true
  else
    say "${e}==>${x} gcov disable"
  fi

  search_in="$search_in $proj_root"
  say "$e==>$x Searching for coverage reports in:"
  for _path in "$search_in"
  do
    say "    ${g}+${x} $_path"
  done
  files=$(find $search_in -type f \( -name '*coverage*.*' \
                     -or -name 'nosetests.xml' \
                     -or -name 'jacoco*.xml' \
                     -or -name 'clover.xml' \
                     -or -name 'report.xml' \
                     -or -name '*.codecov.*' \
                     -or -name 'codecov.*' \
                     -or -name 'cobertura.xml' \
                     -or -name 'luacov.report.out' \
                     -or -name 'coverage-final.json' \
                     -or -name 'naxsi.info' \
                     -or -name 'lcov.info' \
                     -or -name 'lcov.dat' \
                     -or -name '*.lcov' \
                     -or -name 'cover.out' \
                     -or -name 'gcov.info' \
                     -or -name '*.gcov' \
                     -or -name '*.lst' \) \
                    -not -name '*.sh' \
                    -not -name '*.bash' \
                    -not -name '*.data' \
                    -not -name '*.py' \
                    -not -name '*.class' \
                    -not -name '*.xcconfig' \
                    -not -name '*.ec' \
                    -not -name '*.coverage' \
                    -not -name 'Coverage.profdata' \
                    -not -name 'coverage-summary.json' \
                    -not -name 'phpunit-code-coverage.xml' \
                    -not -name 'coverage.serialized' \
                    -not -name '*codecov.yml' \
                    -not -name '*.pyc' \
                    -not -name '*.cfg' \
                    -not -name '*.egg' \
                    -not -name '*.css' \
                    -not -name '*.less' \
                    -not -name '*.whl' \
                    -not -name '*.html' \
                    -not -name '*.erb' \
                    -not -name '*.js' \
                    -not -name '*.md' \
                    -not -name '*.cpp' \
                    -not -name 'coverage.jade' \
                    -not -name 'coverage.db' \
                    -not -name 'include.lst' \
                    -not -name 'inputFiles.lst' \
                    -not -name 'createdFiles.lst' \
                    -not -name 'coverage.html' \
                    -not -name 'scoverage.measurements.*' \
                    -not -name 'test_*_coverage.txt' \
                    -not -name '*.cmake' \
                    -not -path '*/vendor/*' \
                    -not -path '*/htmlcov/*' \
                    -not -path '*/home/cainus/*' \
                    -not -path '*/virtualenv/*' \
                    -not -path '*/js/generated/coverage/*' \
                    -not -path '*/.virtualenv/*' \
                    -not -path '*/virtualenvs/*' \
                    -not -path '*/.virtualenvs/*' \
                    -not -path '*/.env/*' \
                    -not -path '*/.envs/*' \
                    -not -path '*/env/*' \
                    -not -path '*/envs/*' \
                    -not -path '*/.venv/*' \
                    -not -path '*/.venvs/*' \
                    -not -path '*/venv/*' \
                    -not -path '*/venvs/*' \
                    -not -path '*/.git/*' \
                    -not -path '*/.hg/*' \
                    -not -path '*/.tox/*' \
                    -not -path '*/__pycache__/*' \
                    -not -path '*/.egg-info*' \
                    -not -path "*/$bower_components/*" \
                    -not -path '*/node_modules/*' \
                    -not -path '*/conftest_*.c.gcov' 2>/dev/null)

  num_of_files=$(echo "$files" | wc -l | tr -d ' ')
  if [ "$num_of_files" != '' ] && [ "$files" != '' ];
  then
    say "    ${e}->${x} Found $num_of_files reports"
  fi

  # Python coveragepy generation
  if [ "$ft_coveragepy" = "1" ];
  then
    if which coverage >/dev/null 2>&1;
    then
      say "${e}==>${x} Python coveragepy exists ${e}disable via -X coveragepy${x}"

      # find the .coverage
      if [ "$verbose" = "1" ];
      then
        say "    ${e}->${x} Searching for .coverage file"
        find "$git_root" \( -name '.coverage' -or -name '.coverage.*' \) -not -path '.coveragerc'
      fi
      dotcoverage=$(find "$git_root" \( -name '.coverage' -or -name '.coverage.*' \) -not -path '.coveragerc' | head -1)
      cd "$(dirname "$dotcoverage")"
      if [ "$dotcoverage" != "" ];
      then
        say "    ${e}->${x} Running coverage xml"
        if [ "$(coverage xml -i)" != "No data to report." ];
        then
          files="$files
coverage.xml"
        else
          say "    ${r}No data to report.${x}"
        fi
      else
        say "    ${r}No .coverage file found.${x}"
      fi
    else
      say "${e}==>${x} Python coveragepy not found"
    fi
  else
    say "${e}==>${x} Python coveragepy disabled"
  fi
fi

# no files found
if [ "$files" = "" ];
then
  say "${r}-->${x} No coverage report found."
  say "    Please visit https://github.com/codecov and search for your projects language to learn how to collect reports."
  exit ${exit_with};
fi

say "${e}==>${x} Detecting git/mercurial file structure"
network=$(cd "$git_root" && git ls-files 2>/dev/null || hg locate 2>/dev/null || echo "")
if [ "$network" = "" ];
then
  network=$(find "$git_root" -type f \
                 -not -path '*/virtualenv/*' \
                 -not -path '*/.virtualenv/*' \
                 -not -path '*/virtualenvs/*' \
                 -not -path '*/.virtualenvs/*' \
                 -not -path '*.png' \
                 -not -path '*.gif' \
                 -not -path '*.jpg' \
                 -not -path '*.jpeg' \
                 -not -path '*.md' \
                 -not -path '*/.env/*' \
                 -not -path '*/.envs/*' \
                 -not -path '*/env/*' \
                 -not -path '*/envs/*' \
                 -not -path '*/.venv/*' \
                 -not -path '*/.venvs/*' \
                 -not -path '*/venv/*' \
                 -not -path '*/venvs/*' \
                 -not -path '*/build/lib/*' \
                 -not -path '*/.git/*' \
                 -not -path '*/.egg-info/*' \
                 -not -path '*/shunit2-2.1.6/*' \
                 -not -path '*/vendor/*' \
                 -not -path '*/js/generated/coverage/*' \
                 -not -path '*/__pycache__/*' \
                 -not -path '*/node_modules/*' \
                 -not -path "*/$bower_components/*")
fi

upload="$network
<<<<<< network"

# Append Environment Variables
if [ "$env" != "" ];
then
  inc_env=""
  say "${e}==>${x} Appending build variables"
  for varname in $(echo "$env" | tr ',' ' ')
  do
    if [ "$varname" != "" ];
    then
      say "    ${g}+${x} $e"
      inc_env="$inc_env$varname=$(eval echo "\$$varname")
"
    fi
  done

  upload="$inc_env<<<<<< ENV
$upload"
fi

# Append Reports
say "${e}==>${x} Reading reports"
while IFS='' read -r file;
do
  # read the coverage file
  if [ "$(echo "$file" | tr -d ' ')" != '' ];
  then
    if [ -f "$file" ];
    then
      report=$(cat "$file")
      if [ "$report" != "" ];
      then
        say "    ${g}+${x} $file ${e}bytes=${#report}${x}"
        # append to to upload
        upload="$upload
# path=$(echo "$file" | sed "s|^$git_root/||")
$report
<<<<<< EOF"
      else
        say "    ${r}-${x} Skipping empty file $file"
      fi
    else
      say "    ${r}-${x} file not found at $file"
    fi
  fi
done <<< "$(echo -e "$files")"

if [ "$ft_fix" = "1" ];
then
  if [ "$(find "$git_root" -name '*.go' -or -name '*.php' -or -name '*.kt' -or -name '*.swift' -or -name '*.m')" != "" ];
  then
    say "${e}==>${x} Appending adjustments (http://bit.ly/1O4eBpt)"
    adjustments=""
    if [[ $(echo "$network" | grep '.kt$') != '' ]];
    then
      adjustments="$adjustments
$(find "$git_root" -type f -name '*.kt' -exec wc -l {} \; | while read l; do echo "EOF: $l"; done)
$(find "$git_root" -type f -name '*.kt' -exec grep -nIH '^/\*' {} \;)"
    fi
    if [[ $(echo "$network" | grep '.go$') != '' ]];
    then
      adjustments="$adjustments
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.go' -exec grep -nIH '^[[:space:]]*$' {} \;)
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.go' -exec grep -nIH '^[[:space:]]*//.*' {} \;)
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.go' -exec grep -nIH '^[[:space:]]*/\*' {} \;)
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.go' -exec grep -nIH '^[[:space:]]*\*/' {} \;)
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.go' -exec grep -nIH '^[[:space:]]*}$' {} \;)"
    fi
    if [[ $(echo "$network" | grep '.jsx$') != '' ]];
    then
      adjustments="$adjustments
$(find "$git_root" -type f -name '*.jsx' -exec grep -nIH '^[[:space:]]*$' {} \;)
$(find "$git_root" -type f -name '*.jsx' -exec grep -nIH '^[[:space:]]*//.*' {} \;)
$(find "$git_root" -type f -name '*.jsx' -exec grep -nIH '^[[:space:]]*/\*' {} \;)
$(find "$git_root" -type f -name '*.jsx' -exec grep -nIH '^[[:space:]]*\*/' {} \;)
$(find "$git_root" -type f -name '*.jsx' -exec grep -nIH '^[[:space:]]*}$' {} \;)"
    fi
    if [[ $(echo "$network" | grep '.php$') != '' ]];
    then
      adjustments="$adjustments
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.php' -exec grep -nIH '^[[:space:]]*[\{\}\\[][[:space:]]*$' {} \;)
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.php' -exec grep -nIH '^[[:space:]]*);[[:space:]]*$' {} \;)
$(find "$git_root" -type f -not -path '*/vendor/*' -name '*.php' -exec grep -nIH '^[[:space:]]*][[:space:]]*$' {} \;)"
    fi
    if [[ $(echo "$network" | grep '(.cpp|.h|.cxx|.c|.hpp)$') != '' ]];
    then
      adjustments="$adjustments
$(find "$git_root" -type f \( -name '*.h' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.c' -or -name '*.hpp' \) -exec grep -nIH '^}' {} \;)
$(find "$git_root" -type f \( -name '*.h' -or -name '*.cpp' -or -name '*.cxx' -or -name '*.c' -or -name '*.hpp' \) -exec grep -nIH '// LCOV_EXCL_' {} \;)"
    fi
    if [[ $(echo "$network" | grep '.m$') != '' ]];
    then
      adjustments="$adjustments
$(find "$git_root" -type f -name '*.m' -exec grep -nIH '^[[:space:]]*}$' {} \;)"
    fi
    found=$(echo "$adjustments" | wc -l | tr -d ' ')
    if [ "$found" != "1" ];
    then
      say "    ${g}+${x} Found $found adjustments"
      upload="$upload
# path=fixes
$adjustments
<<<<<< EOF"
    else
      say "    ${e}->${x} Found 0 adjustments"
    fi
  fi
fi

if [ "$url_o" != "" ];
then
  url="$url_o"
fi
# trim whitespace from query

if [ "$dump" != "0" ];
then
  echo "$url/upload/v4?$(echo "package=bash-$VERSION&token=$token&$query" | tr -d ' ')"
  echo "$upload"
else

  query=$(echo "${query}" | tr -d ' ')
  say "${e}==>${x} Uploading reports"
  say "    ${e}url:${x} $url"
  say "    ${e}query:${x} $query"

  # now add token to query
  query=$(echo "package=bash-$VERSION&token=$token&$query" | tr -d ' ')

  say "    ${e}->${x} Pinging Codecov"
  res=$(curl -sX $cacert POST "$url/upload/v4?$query" -H 'Accept: text/plain' || true)
  # a good replay is "https://codecov.io" + "\n" + "https://codecov.s3.amazonaws.com/..."
  status=$(echo "$res" | head -1 | grep 'HTTP ' | cut -d' ' -f2)
  if [ "$status" = "" ];
  then
    s3target=$(echo "$res" | sed -n 2p)
    say "    ${e}->${x} Uploading to S3 $(echo "$s3target" | cut -c1-32)"
    s3=$(echo "$upload" | \
         curl -fisX PUT --data-binary @- \
              -H 'Content-Type: text/plain' \
              -H 'x-amz-acl: public-read' \
              -H 'x-amz-storage-class: REDUCED_REDUNDANCY' \
              "$s3target" || true)
    if [ "$s3" != "" ];
    then
      say "    ${g}->${x} View reports at ${b}$(echo "$res" | sed -n 1p)${x}"
      exit 0
    else
      say "    ${r}X> Failed to upload to S3${n}"
    fi
  elif [ "$status" = "400" ];
  then
      # 400 Error
      say "${g}${res}${x}"
      exit ${exit_with}
  fi

  say "    ${e}->${x} Uploading to Codecov"
  i="0"
  while [ $i -lt 4 ]
  do
    i=$[$i+1]

    res=$(echo "$upload" | curl -sX POST $cacert --data-binary @- "$url/upload/v2?$query" -H 'Accept: text/plain' || echo 'HTTP 500')
    # HTTP 200
    # http://....
    status=$(echo "$res" | head -1 | cut -d' ' -f2)
    if [ "$status" = "" ];
    then
      say "    View reports at ${b}$(echo "$res" | head -2 | tail -1)${x}"
      exit 0

    elif [ "${status:0:1}" = "5" ];
    then
      say "    ${e}->${x} Sleeping for 10s and trying again..."
      sleep 10

    else
      say "    ${g}${res}${x}"
      exit 0
      exit ${exit_with}
    fi

  done

fi

say "    ${r}X> Failed to upload coverage reports${x}"
exit ${exit_with}

# EOF
