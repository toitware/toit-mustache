// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

/**
An extension to the Mustache template syntax.

Mustache instructions can be added in comments, so that the code still
  remains valid Toit (or other) code.

Additionally, a simple replacement mechanism is provided to replace
  patterns in the template with values from the input.

# Example
```
// MUSTACHE: {{#methods}} Enter the 'methods' section.
// MUSTACHE: method-name={{name}}
/**
// MUSTACHE: {{description}}
*/
method-name
    // MUSTACHE: -- a comment that will be removed from the output.
    // MUSTACHE: {{#parameters}} Enter parameters.
    // MUSTACHE: parameter-name={{name}}
    --parameter-name
    // MUSTACHE: {{/parameters}} Exit parameters.
:
  print "in method"
// MUSTACHE: {{/methods}} Exit the 'methods' section.
```
*/

/**
Converts a string containing Mustache comments into a valid Mustache template.

See this library's Toitdoc for more information.

Note that the implementation is relatively dumb. Specifically, replacements are never
  removed. They also don't match full identifiers. If one replacement is a subsection of
  another replacement, then the order of replacement matters.
*/
comment-template-to-mustache str/string -> string:
  lines := str.split "\n"
  replacements := {:}
  result := []
  lines.do: | line/string |
    trimmed := line.trim
    if trimmed.starts-with "// MUSTACHE: --":
      // Skip line.
    else if trimmed.starts-with "// MUSTACHE: ":
      trimmed = trimmed.trim --left "// MUSTACHE: "
      last-curly := trimmed.index-of --last "}"
      if last-curly != -1:
        trimmed = trimmed[..last-curly + 1]
      if trimmed.contains "=":
        parts := trimmed.split "="
        replacements[parts[0]] = parts[1]
      else:
        result.add trimmed
    else:
      replacements.do: | pattern/string replacement/string |
        line = line.replace --all pattern replacement
      result.add line
  return result.join "\n"
