# Mustache

A [Mustache](https://mustache.github.io/) template engine for Toit.

This package also supports a comment variant of Mustache that makes it
  more convenient to write templates, as the mustache syntax is hidden in
  comments.

## Usage

Call `parse` to parse a Mustache template. Then call `render` with the
  input, and optional `partials` to render the parsed template.

## Comment Mustache

Here is an example of the comment version of Mustache templates:

```toit
// MUSTACHE: -- Note that this file is valid Toit.
// MUSTACHE: ClassName={{name}}
class ClassName:
  // MUSTACHE: {{#methods}}  Enter methods.
  // MUSTACHE: method-name={{name}}
  method-name
      // MUSTACHE: {{#parameters}}  Enter parameters.
      // MUSTACHE: {{#required}}  If the parameter is required.
      // MUSTACHE: required-param={{name}}
      --required-param
      // MUSTACHE: {{/required}}  Leave required.
      // MUSTACHE: {{^required}}  If the parameter is not required.
      // MUSTACHE: optional-param={{name}}
      --optional-param=null
      // MUSTACHE: {{/required}}  Leave optional parameters.
      // MUSTACHE: {{/parameters}}
  :
    // MUSTACHE: {{#parameters}}
    // MUSTACHE: -- We are using the required-param parameter, as a stand-in for
    // MUSTACHE: -- all parameters.
    print "{{name}}=$required-param"
    // MUSTACHE: {{/parameters}}

  // MUSTACHE: {{/methods}}
```
