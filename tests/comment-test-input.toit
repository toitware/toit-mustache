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
