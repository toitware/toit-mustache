// Copyright (C) 2025 Toit contributors.
// Use of this source code is governed by a MIT-style license that can be found
// in the LICENSE file.

import .node

class Renderer implements Visitor:
  main-template/List  // Of Node.
  partials/Map  // String to List of Node.
  inputs/List := []  // The input stack. New section push their specialization.
  indentation/string := ""  // The current indentation.
  strict/bool
  inheritance-stack := []  // Of List of PartialInheritanceNode.

  constructor .main-template .partials input --.strict=false:
    inputs.add input

  render -> string:
    return render-nodes main-template

  render-nodes nodes/List -> string:
    result := ""
    if indentation != "" and not nodes.is-empty:
      result = indentation
    for i := 0; i < nodes.size; i++:
      node/Node := nodes[i]
      is-last := i == nodes.size - 1
      result += render-node node --is-last=is-last
    return result

  render-node node/Node --is-last/bool -> string:
    if node is TextNode:
      return render-text (node as TextNode) --is-last=is-last
    return node.accept this

  indent_ str/string -> string:
    return str.replace "\n" "\n$indentation"

  visit-text node/TextNode -> string:
    // The visitor is short-cut for text nodes.
    unreachable

  render-text node/TextNode --is-last/bool -> string:
    text := node.text
    if indentation == "": return text
    if is-last and text[text.size - 1] == '\n':
      // Don't add indentation if the text ends with a newline.
      return "$(indent_ text[..text.size - 1])\n"
    return indent_ text

  visit-variable node/VariableNode -> string:
    value := lookup-value node.name
    if not value: return ""
    if node.escape:
      return html-escape "$value"
    return "$value"

  visit-section node/SectionNode -> string:
    value := lookup-value node.name
    if node.inverted:
      if not value or (value is List and value.is-empty) or (value is Map and value.is-empty):
        return render-nodes node.children
      return ""
    else:
      if not value:
        return ""
      if value is bool:
        return render-nodes node.children
      if value is List:
        result := ""
        value.do: | item |
          result += render-nodes-with-context node.children item
        return result
      return render-nodes-with-context node.children value

  render-partial partial-name/string indentation/string -> string:
    partial-template := partials.get partial-name
    if not partial-template:
      if strict:
        throw "Partial not found: $partial-name"
      return ""
    old-indentation := this.indentation
    this.indentation += indentation
    result := render-nodes partial-template
    this.indentation = old-indentation
    return result

  visit-partial-concrete node/PartialConcreteNode -> string:
    return render-partial node.name node.indentation

  visit-partial-dynamic node/PartialDynamicNode -> string:
    partial-name := lookup-value node.partial-field
    if not partial-name:
      if strict:
        throw "Partial field not found: $node.partial-field"
      return ""
    return render-partial partial-name node.indentation

  is-indentation-char c/int -> bool:
    return c == ' ' or c == '\t'

  extract-line-indentation text/string -> string:
    for i := 0; i < text.size; i++:
      c := text.at --raw i
      if not is-indentation-char c: return text[..i]
    return text

  merge-indentation indent1/string? indent2/string -> string:
    if not indent1: return indent2
    if indent2.size < indent1.size:
      tmp := indent1
      indent1 = indent2
      indent2 = tmp
    for i := 0; i < indent1.size; i++:
      if (indent1.at --raw i) != (indent2.at --raw i): return indent1[..i]
    return indent1

  extract-indentation text/string -> string:
    indent/string? := null
    while true:
      indent = merge-indentation indent (extract-line-indentation text)
      if indent == "": return ""
      next-line := text.index-of "\n"
      if next-line < 0: return indent
      text = text[next-line + 1..]
      if text == "": return indent

  block-indentation node/BlockNode -> string:
    if node.is-standalone and not node.children.is-empty and node.children.first is TextNode:
      return extract-indentation (node.children.first as TextNode).text
    return node.indentation

  replace-indentation text/string --new-indentation -> string:
    text-indentation := extract-indentation text
    if text-indentation == new-indentation: return text
    text = text.trim --left text-indentation
    text = new-indentation + text
    text = text.replace --all "\n$text-indentation" "\n$new-indentation"
    if text.ends-with "\n$new-indentation":
      text = text[..text.size - new-indentation.size]
    return text

  visit-block node/BlockNode -> string:
    name := node.name
    render-node := node
    for i := inheritance-stack.size - 1; i >= 0; i--:
      inheritance/PartialInheritanceNode := inheritance-stack[i]
      inheritance.overridden.get name --if-present=: render-node = it
    result := render-nodes render-node.children
    if render-node != node:
      // The block was replaced.
      // Switch the indentation.
      node-indentation := this.indentation
      node-indentation += block-indentation node
      result = replace-indentation result --new-indentation=node-indentation
    return result

  visit-partial-inheritance node/PartialInheritanceNode -> string:
    inheritance-stack.add node
    result := render-partial node.name node.indentation
    inheritance-stack.resize (inheritance-stack.size - 1)
    return result

  render-nodes-with-context nodes/List context/any -> string:
    inputs.add context
    result := render-nodes nodes
    inputs.resize (inputs.size - 1)
    return result

  lookup-value name/string -> any:
    not-found := :
      if not strict: return null
      throw "Key not found: $name"

    if name == ".":
      return inputs.last

    name-parts := name.split "."
    first := name-parts.first
    // The first lookup must go up the stack if it can't find the entry.
    current/any := null
    for i := inputs.size - 1; i >= 0; i--:
      input := inputs[i]
      if input is not Map: continue
      if not (input as Map).contains first: continue
      current = input
      break

    name-parts.do: | part |
      if current is not Map: not-found.call
      current = current.get part --if-absent=not-found
    return current

  html-escape value/string -> string:
    value = value.replace --all "&" "&amp;"
    value = value.replace --all "<" "&lt;"
    value = value.replace --all ">" "&gt;"
    value = value.replace --all "\"" "&quot;"
    value = value.replace --all "'" "&#39;"
    return value

render template/List --partials/Map={:} --input/any --strict/bool=false -> string:
  renderer := Renderer template partials input --strict=strict
  return renderer.render
