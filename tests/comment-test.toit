// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the tests/LICENSE file.

import expect show *
import fs
import host.file
import mustache
import system

EXPECTED-TEMPLATE ::= """
  class {{name}}:
  {{#methods}}
    {{name}}
  {{#parameters}}
  {{#required}}
        --{{name}}
  {{/required}}
  {{^required}}
        --{{name}}=null
  {{/required}}
  {{/parameters}}
    :
  {{#parameters}}
      print "{{name}}=\${{name}}"
  {{/parameters}}

  {{/methods}}
  """

EXPECTED-FILLED ::= """
  class Foo:
    method1
        --required1
        --required2
    :
      print "required1=\$required1"
      print "required2=\$required2"

    method2
        --required
        --optional1=null
        --optional2=null
    :
      print "required=\$required"
      print "optional1=\$optional1"
      print "optional2=\$optional2"

  """

VALUES ::= {
    "name": "Foo",
    "methods": [
      {
        "name": "method1",
        "parameters": [
          { "name": "required1", "required": true },
          { "name": "required2", "required": true },
        ],
      },
      {
        "name": "method2",
        "parameters": [
          { "name": "required", "required": true },
          { "name": "optional1" },
          { "name": "optional2" },
        ],
      }
    ]
  }

main:
  my-path := fs.dirname system.program-path
  input-path := fs.join my-path "comment-test-input.toit"
  input := (file.read-contents input-path).to-string
  converted := mustache.comment-template-to-mustache input
  expect-equals EXPECTED-TEMPLATE converted
  parsed := mustache.parse converted
  rendered := mustache.render parsed --input=VALUES
  expect-equals EXPECTED-FILLED rendered
