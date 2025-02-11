test_that("tidy upkeep bullets don't change accidentally", {
  withr::local_options(
    usethis.description = list(
      "Authors@R" = utils::person(
        "Jane", "Doe",
        email = "jane@rstudio.com",
        role = c("aut", "cre")
      ),
      License = "MIT + file LICENSE"
    )
  )
  create_local_package()

  expect_snapshot(
    writeLines(tidy_upkeep_checklist(posit_pkg = TRUE, posit_person_ok = FALSE)),
    transform = scrub_checklist_footer
  )
})

test_that("upkeep bullets don't change accidentally",{
  skip_if_no_git_user()
  withr::local_options(usethis.description = NULL)
  create_local_package()
  local_mocked_bindings(git_default_branch = function() "main")
  use_cran_comments()

  expect_snapshot(
    writeLines(upkeep_checklist()),
    transform = scrub_checklist_footer
  )

  # Add some files to test conditional todos
  use_code_of_conduct("jane.doe@foofymail.com")
  use_testthat()
  withr::local_file("cran-comments.md")
  writeLines(
    "## Test environments\\n\\n* local Ubuntu\\n\\# R CMD check results\\n", 
    "cran-comments.md"
  )
  local_mocked_bindings(git_default_branch = function() "master")

  expect_snapshot({
    local_edition(2L)
    writeLines(upkeep_checklist())
  },
  transform = scrub_checklist_footer
  )
})

test_that("get extra upkeep bullets works", {
  env <- env(upkeep_bullets = function() c("extra", "upkeep bullets"))
  expect_equal(upkeep_extra_bullets(env),
               c("* [ ] extra", "* [ ] upkeep bullets", ""))

  env <- NULL
  expect_equal(upkeep_extra_bullets(env), "")
})
