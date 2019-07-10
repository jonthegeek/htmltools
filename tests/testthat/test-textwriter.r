context("textwriter")

describe("TextWriter", {
  it("basically works", {
    tw <- TextWriter$new()
    on.exit(tw$close())

    expect_identical(tw$readAll(), "")

    tw$write("")
    expect_identical(tw$readAll(), "")

    tw$write("line one")
    expect_identical(tw$readAll(), "line one")

    tw$write("\nanother line")
    expect_identical(tw$readAll(), "line one\nanother line")

    tw$write("more content")
    expect_identical(tw$readAll(), "line one\nanother linemore content")
  })

  it("bookmarks are respected", {
    tw <- TextWriter$new()
    on.exit(tw$close())

    tw$restorePosition()
    expect_identical(tw$readAll(), "")

    tw$write("foo")
    tw$restorePosition()
    expect_identical(tw$readAll(), "")

    tw$write("bar")
    tw$savePosition()
    tw$restorePosition()
    expect_identical(tw$readAll(), "bar")

    tw$write(" baz")
    tw$write(" qux")
    expect_identical(tw$readAll(), "bar baz qux")
    tw$restorePosition()
    expect_identical(tw$readAll(), "bar")

    # multi-byte characters are ok
    tw$write("\U0001f609abc")
    expect_identical(tw$readAll(), "bar\U0001f609abc")
    tw$restorePosition()
    expect_identical(tw$readAll(), "bar")

    tw$write("\U0001f57a123")
    expect_identical(tw$readAll(), "bar\U0001f57a123")

  })
})

describe("WSTextWriter", {
  it("eats past and future whitespace", {
    wtw <- WSTextWriter()#$new()

    expect_identical(wtw$readAll(), "")
    wtw$writeWS("   ")
    expect_identical(wtw$readAll(), "   ")
    wtw$writeWS("   ")
    wtw$writeWS("   ")
    wtw$eatWS()
    expect_identical(wtw$readAll(), "")
    wtw$writeWS("   ")
    wtw$writeWS("   ")
    wtw$writeWS("   ")
    expect_identical(wtw$readAll(), "")

    wtw$write("Hello")
    expect_identical(wtw$readAll(), "Hello")
    wtw$writeWS("  ")
    expect_identical(wtw$readAll(), "Hello  ")
    wtw$eatWS()
    expect_identical(wtw$readAll(), "Hello")
    wtw$writeWS("  ")
    expect_identical(wtw$readAll(), "Hello")
  })
})

describe("validateNoWS",{
  it("basically works", {
    validateNoWS(NULL)
    validateNoWS(noWSOptions[1])
    validateNoWS(noWSOptions[1:2])
    validateNoWS(noWSOptions)
    expect_error(validateNoWS("badOption"))
    expect_error(validateNoWS(c(noWSOptions, "badOption")))

    # capitalization matters
    expect_error(validateNoWS(toupper(noWSOptions[1])))
  })
})
