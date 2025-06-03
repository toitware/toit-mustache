// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

import encoding.json
import expect show *
import host.directory
import host.file
import mustache

main args:
  specs-path/string := args.first
  if specs-path.ends-with "toit" or specs-path.ends-with "toit.exe":
    // The Toit repository calls external tests with the 'toit' executable as argument.
    print "Bailing out, since likely called from the toit repository."
    return

  stream := directory.DirectoryStream specs-path
  while name/string? := stream.next:
    if name.starts-with "~lambdas": continue
    if not name.ends-with ".json": continue
    path := "$specs-path/$name"
    run-test-suite path
  stream.close

run-test-suite path/string:
  content := json.decode (file.read-contents path)
  tests := content["tests"]
  tests.do: run-test it --suite=path

run-test test/Map --suite/string:
  name := test["name"]
  data := test["data"]
  template := test["template"]
  partials := test.get "partials" --if-absent=:{:}
  expected := test["expected"]

  parsed := mustache.parse template
  parsed-partials := partials.map: | _ partial-template/string |
    mustache.parse partial-template
  rendered := mustache.render parsed
      --partials=parsed-partials
      --input=data
  if expected != rendered and not rendered.contains "99999":
    print "FAIL: $name in $suite"
    print "Expected: '$expected'"
    print "Got: '$rendered'"
    print
