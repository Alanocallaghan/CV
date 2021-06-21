library("tidyverse")
library("stringr")
library("stringi")
library("glue")
simplify_name <- function(n) {
 ## Extract just the name, removing any quotes, and normalize accented characters 
 stri_trans_general(str_trim(str_match(n,"^[\'\"]?([^\'\",(<]+).*<")[,2]),"latin-ascii")       
}
pkglist <- tools::CRAN_package_db()
pkglist <- tbl_df(pkglist[-40]) ## remove duplicate MD5sum column
pkglist %>% 
 select(Maintainer, Author, Package) %>% 
 arrange(Maintainer) -> authors
authors %>% 
 mutate(Maint = simplify_name(Maintainer)) -> maintainers

maintainers %>% filter(Maint == "Alan O'Callaghan")


simplify_author <- function(n) {
    strsplit(n, ",(?![^[]*\\])", perl = TRUE)[[1]]
}

glue_me <- function(ctb, cre) {
  glue(
    "
    \\begin{itemize}
      \\item
        Maintainer: <cre>
      \\item
        Contributor: <ctb>
    \\end{itemize}
    ",
    .open = "<",
    .close = ">",
    cre = cre,
    ctb = ctb
  )
}


authors <- lapply(pkglist$Author, simplify_author)
authors <- lapply(authors, function(a) gsub("\\[.*\\]", "", a))
authors <- lapply(authors, function(a) gsub("\\n", "", a))
authors <- lapply(authors, function(a) gsub("\\(.*\\)", "", a))
authors <- lapply(authors, function(a) gsub("<.*>", "", a))
authors <- lapply(authors, function(a) gsub("\\s+$", "", a))
authors <- lapply(authors, function(a) gsub("^\\s+", "", a))
ind_me <- sapply(authors, function(a) "Alan O'Callaghan" %in% a)
my_cran <- pkglist[ind_me, ]
ind_maintainer <- grepl("Alan O'Callaghan", my_cran$Maintainer)

cran_pkgs <- glue("\\href{<url>}{<name>}",
  url = sapply(my_cran$URL, function(a) strsplit(a, ",")[[1]][[1]]),
  name = my_cran$Package,
  .open = "<",
  .close = ">"
)
cran_cre <- paste(cran_pkgs[ind_maintainer], collapse = ", ")
cran_ctb <- paste(cran_pkgs[!ind_maintainer], collapse = ", ")


cran <- glue_me(cran_ctb, cran_cre)
cat(cran, file = "cv-sections/cran_pkgs.tex")


bp <- BiocPkgTools::biocPkgList(version = "devel")
my_bioc <- bp[sapply(bp$Author, function(a) "Alan O'Callaghan" %in% a), ]
ind_maintainer <- grepl("Alan O'Callaghan", my_bioc$Maintainer)

bioc_pkgs <- glue("\\href{<url>}{<name>}",
  url = my_bioc$URL,
  name = my_bioc$Package,
  .open = "<",
  .close = ">"
)
bioc_cre <- paste(bioc_pkgs[ind_maintainer], collapse = ", ")
bioc_ctb <- paste(bioc_pkgs[!ind_maintainer], collapse = ", ")


bioc <- glue_me(bioc_ctb, bioc_cre)
cat(bioc, file = "cv-sections/bioc_pkgs.tex")
