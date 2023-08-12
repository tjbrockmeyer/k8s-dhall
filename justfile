
_files cmd:
  #!/usr/bin/env bash
  for dir in $(find ./kd/ -type d); do
    if [[ -n "$dir"/*.dhall ]]; then
      dhall {{cmd}} "$dir"/*.dhall
    fi
  done

_dirs cmd:
  #!/usr/bin/env bash
  for d in $(find ./kd -type d | tail -n +2); do
    if [[ -n "$d"/*.dhall ]]; then
      dhall {{cmd}} "$d"
    fi
  done

freeze:
  #!/usr/bin/env bash
  for file in $(find ./kd/ -type f -name '*.dhall'); do
    if ! dhall freeze --check $file &>/dev/null
    then dhall freeze $file
    fi
  done

format:
  #!/usr/bin/env bash
  for file in $(find ./ -type f -name '*.dhall'); do
      dhall format $file
  done

check:
  - dhall --explain type --quiet --file ./kd/package.dhall

package:
  - just _dirs package
  - just freeze
  - just _files lint
  - just check

kube action files:
  #!/usr/bin/env bash
  set -ex
  files="{{files}}"
  # check files validities
  for file in $files; do
    if [[ -f ./cluster/$file.dhall ]]
    then dhall --file ./cluster/$file.dhall >/dev/null
    fi
  done
  # apply all files
  for file in $files; do
    if [[ -f ./cluster/$file.dhall ]]
    then kubectl {{action}} -f - <<< "$( dhall-to-yaml --documents --file "./cluster/$file.dhall" )"
    elif [[ -f ./cluster/$file.uri ]]
    then kubectl {{action}} -f $(cat ./cluster/$file.uri)
    fi
  done
