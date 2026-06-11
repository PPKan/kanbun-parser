# frozen_string_literal: true

require "rexml/document"
require "rexml/xpath"
require_relative "test_helper"

class CSLStyleTest < Minitest::Test
  def test_contributors_use_japanese_list_delimiter
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    author_name = REXML::XPath.first(style, "//*[local-name()='macro' and @name='contributors']/*[local-name()='names' and @variable='author']/*[local-name()='name']")
    editor_name = REXML::XPath.first(style, "//*[local-name()='macro' and @name='contributors']/*[local-name()='names' and @variable='author']/*[local-name()='substitute']/*[local-name()='names' and @variable='editor']/*[local-name()='name']")

    assert_equal "、", author_name.attributes["delimiter"]
    assert_equal "、", editor_name.attributes["delimiter"]
  end

  def test_editor_substitute_adds_kochu_suffix
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    editor_names = REXML::XPath.first(style, "//*[local-name()='macro' and @name='contributors']/*[local-name()='names' and @variable='author']/*[local-name()='substitute']/*[local-name()='names' and @variable='editor']")

    assert_equal "（校注）", editor_names.attributes["suffix"]
  end

  def test_book_title_uses_double_corner_brackets
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    book_title = REXML::XPath.first(style, "//*[local-name()='macro' and @name='title']/*[local-name()='choose']/*[local-name()='if' and @match='any' and @type='book collection']/*[local-name()='text']")

    assert_equal "『", book_title.attributes["prefix"]
    assert_equal "』", book_title.attributes["suffix"]
  end

  def test_paper_title_uses_corner_brackets
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    paper_title = REXML::XPath.first(style, "//*[local-name()='macro' and @name='title']/*[local-name()='choose']/*[local-name()='else']/*[local-name()='text']")

    assert_equal "「", paper_title.attributes["prefix"]
    assert_equal "」", paper_title.attributes["suffix"]
  end

  def test_webpage_publication_uses_website_and_year
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    webpage_group = REXML::XPath.first(style, "//*[local-name()='macro' and @name='publication']/*[local-name()='choose']/*[local-name()='if' and @type='webpage']//*[local-name()='group']")
    website_text = REXML::XPath.first(webpage_group, "./*[local-name()='text' and @macro='website']")
    year_text = REXML::XPath.first(webpage_group, "./*[local-name()='text' and @macro='year']")

    assert_equal "（", webpage_group.attributes["prefix"]
    assert_equal "）", webpage_group.attributes["suffix"]
    assert_equal "、", webpage_group.attributes["delimiter"]
    refute_nil website_text
    refute_nil year_text
  end

  def test_webpage_year_adds_access_marker
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    issued_date = REXML::XPath.first(style, "//*[local-name()='macro' and @name='year']//*[local-name()='date' and @variable='issued']")
    accessed_date = REXML::XPath.first(style, "//*[local-name()='macro' and @name='year']//*[local-name()='date' and @variable='accessed']")

    assert_equal "閲", issued_date.attributes["suffix"]
    assert_equal "閲", accessed_date.attributes["suffix"]
  end

  def test_article_journal_publication_uses_journal_volume_issue_and_date
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    article_publication = REXML::XPath.first(style, "//*[local-name()='macro' and @name='publication']/*[local-name()='choose']/*[local-name()='else-if' and @type='article-journal']/*[local-name()='text' and @macro='journal-publication']")
    journal_group = REXML::XPath.first(style, "//*[local-name()='macro' and @name='journal-publication']/*[local-name()='group']")
    journal_title = REXML::XPath.first(journal_group, ".//*[local-name()='text' and @variable='container-title']")
    volume_issue = REXML::XPath.first(journal_group, ".//*[local-name()='group' and @delimiter='-']")
    issued_date = REXML::XPath.first(journal_group, "./*[local-name()='text' and @macro='issued-date']")

    refute_nil article_publication
    assert_equal "（", journal_group.attributes["prefix"]
    assert_equal "）", journal_group.attributes["suffix"]
    assert_equal "、", journal_group.attributes["delimiter"]
    assert_equal "『", journal_title.attributes["prefix"]
    assert_equal "』", journal_title.attributes["suffix"]
    refute_nil volume_issue
    refute_nil issued_date
  end

  def test_webpage_citations_skip_contributors
    style = REXML::Document.new(File.read(style_path, mode: "r:utf-8"))
    webpage_citation_group = REXML::XPath.first(style, "//*[local-name()='citation']/*[local-name()='layout']/*[local-name()='choose']/*[local-name()='if' and @type='webpage']/*[local-name()='group']")
    contributors = REXML::XPath.first(webpage_citation_group, ".//*[local-name()='text' and @macro='contributors']")
    title = REXML::XPath.first(webpage_citation_group, "./*[local-name()='text' and @macro='title']")

    assert_nil contributors
    refute_nil title
  end

  private

  def style_path
    File.join(JPMD::Compiler::APP_ROOT, "references", "word-japanese-note.csl")
  end
end
