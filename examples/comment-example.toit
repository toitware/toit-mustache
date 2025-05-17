// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the examples/LICENSE file.

import expect show *
import fs
import host.file
import mustache
import system

/**
An example of the comment-syntax version.

See the 'comment-input.toit' file for the template.
*/


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
  input-path := fs.join my-path "comment-input.toit"
  input := (file.read-contents input-path).to-string
  // Convert the comment version to a valid Mustache template.
  converted := mustache.comment-template-to-mustache input
  parsed := mustache.parse converted
  // Render it with our values.
  // If necessary, a '--partials' could be used to provide partial templates.
  rendered := mustache.render parsed --input=VALUES
  print rendered
