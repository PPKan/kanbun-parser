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

local writing_mode = "yoko"

local function span_attributes(span)
  if span.attr and span.attr.attributes then
    return span.attr.attributes
  end

  if span.attributes then
    return span.attributes
  end

  return {}
end

local function has_kanbun_attributes(attributes)
  return attributes.f ~= nil or attributes.o ~= nil or attributes.k ~= nil
end

local function has_kanbun_span(inlines)
  for _, inline in ipairs(inlines or {}) do
    if inline.t == "Span" and has_kanbun_attributes(span_attributes(inline)) then
      return true
    end
  end

  return false
end

local function serialize_kanbun_inlines(inlines)
  local parts = {}

  for _, inline in ipairs(inlines or {}) do
    local text = nil

    if inline.t == "Str" then
      text = inline.text == "　" and "" or inline.text
    elseif inline.t == "Space" or inline.t == "SoftBreak" then
      text = ""
    elseif inline.t == "LineBreak" then
      text = "\n"
    elseif inline.t == "Span" then
      local attributes = span_attributes(inline)

      if has_kanbun_attributes(attributes) then
        local base_text = pandoc.utils.stringify(inline)
        local annotated = { base_text }

        if attributes.f and attributes.f ~= "" then
          table.insert(annotated, "(" .. attributes.f .. ")")
        end

        if attributes.o and attributes.o ~= "" then
          table.insert(annotated, "{" .. attributes.o .. "}")
        end

        if attributes.k and attributes.k ~= "" then
          table.insert(annotated, "[" .. attributes.k .. "]")
        end

        text = table.concat(annotated)
      else
        text = serialize_kanbun_inlines(inline.content)
      end
    elseif inline.t == "Emph" or inline.t == "Strong" or inline.t == "Strikeout" or inline.t == "Underline" or inline.t == "SmallCaps" or inline.t == "Superscript" or inline.t == "Subscript" or inline.t == "Quoted" then
      text = serialize_kanbun_inlines(inline.content)
    elseif inline.t == "Code" then
      text = inline.text
    else
      return nil
    end

    if text == nil then
      return nil
    end

    table.insert(parts, text)
  end

  local serialized = table.concat(parts)
  serialized = serialized:gsub("^　+", "")
  serialized = serialized:gsub("^[ \t]+", "")

  return serialized
end

local function render_tate_kanbun_block(inlines)
  local source = serialize_kanbun_inlines(inlines)
  if source == nil or source == "" then
    return nil
  end

  return pandoc.RawBlock(
    "latex",
    table.concat({
      "{",
      "\\Kanbun",
      source,
      "\\EndKanbun",
      "\\printkanbunnopar\\par",
      "}"
    }, "\n")
  )
end

function Meta(meta)
  local mode = meta["jpmd-writing-mode"]
  if mode ~= nil then
    writing_mode = pandoc.utils.stringify(mode)
  end

  return meta
end

function Para(para)
  if writing_mode ~= "tate" or not has_kanbun_span(para.content) then
    return nil
  end

  return render_tate_kanbun_block(para.content)
end

function Plain(plain)
  if writing_mode ~= "tate" or not has_kanbun_span(plain.content) then
    return nil
  end

  return render_tate_kanbun_block(plain.content)
end

function Span(span)
  if writing_mode == "tate" then
    return nil
  end

  local attributes = span_attributes(span)

  if not has_kanbun_attributes(attributes) then
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

return {
  {
    Meta = Meta
  },
  {
    Para = Para,
    Plain = Plain,
    Span = Span
  }
}
