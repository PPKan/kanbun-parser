local function escape_latex(str)
  local replacements = {
    ["\\"] = "\\textbackslash{}",
    ["{"] = "\\{",
    ["}"] = "\\}",
    ["#"] = "\\#",
    ["$"] = "\\$",
    ["%"] = "\\%",
    ["&"] = "\\&",
    ["_"] = "\\_",
    ["^"] = "\\^{}",
    ["~"] = "\\~{}"
  }

  return (tostring(str or ""):gsub("[\\{}#$%%&_~^]", replacements))
end

function Span(span)
  local attributes = {}

  if span.attr and span.attr.attributes then
    attributes = span.attr.attributes
  elseif span.attributes then
    attributes = span.attributes
  end

  if attributes.f == nil and attributes.o == nil and attributes.k == nil then
    return nil
  end

  local base_text = pandoc.utils.stringify(span)

  return pandoc.RawInline(
    "latex",
    string.format(
      "\\kanbun{%s}{%s}{%s}{%s}",
      escape_latex(base_text),
      escape_latex(attributes.f or ""),
      escape_latex(attributes.o or ""),
      escape_latex(attributes.k or "")
    )
  )
end
