
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
  - just _files format

check:
  - dhall --explain type --quiet --file ./kd/package.dhall

package:
  - just _dirs package
  - just freeze
  - just _files lint
  - just check

apply:
  #!/usr/bin/env bash
  set -ex
  files="ns"
  # check files validities
  for file in $files; do
      dhall --file "./cluster/$file.dhall" >/dev/null
  done
  # apply all files
  for file in $files; do
      kubectl apply -f - <<< "$( dhall --file "./cluster/$file.dhall" | dhall-to-yaml --documents )"
  done
