
_files cmd:
  #!/usr/bin/env bash
  for dir in $(find ./kd/ -type d); do
    if [[ -n "$dir"/*.dhall ]]; then
      dhall {{cmd}} "$dir"/*.dhall
    fi
  done

_dirs cmd:
  #!/usr/bin/env bash
  for d in $(find ./kd -type d); do
    if [[ -n "$d"/*.dhall ]]; then
      dhall {{cmd}} "$d"
    fi
  done

format:
  - just _files format

package:
  - just _dirs package
  - just _files freeze
  - just _files lint
  - dhall type --quiet --file ./kd/package.dhall

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
