# quarto-lapreprint Format

![GitHub License](https://img.shields.io/github/license/mps9506/quarto-lapreprint)


This is a typst template for quarto users. The original typst template is from [LaPreprint](https://github.com/LaPreprint/typst)[^distribution] and has been slightly modified for use in quarto.

[^distribution]: This is a modified redistribution of the original LaPreprint](https://github.com/LaPreprint/typst) Typst template created by Rowan Cockett and distributed under the MIT license. 

## Installing

```bash
quarto use template mps9506/quarto-lapreprint
```

This will install the format extension and create an example qmd file
that you can use as a starting place for your document.

## Using

The yaml header in [template.qmd](template.qmd) provides example starting points.

### Logos and branding

The theme of the document can be set to a specific color, which changes the headers and links. The default `theme` is blue. Change to red (or purple) using:

```yaml
theme: "`red.darken(50%)`{=typst}"
```
You can also supply a logo, which is either an image file location or content, allowing you to add additional information about the journal or lab-group to the top-right of the document. You can also set the `mainfont` which must be the name of a locally installed font.

```yaml
logo: my-logo.png
theme: "`red.darken(50%)`{=typst}"
mainfont: "Fira Sans"
```

## Title and Subtitle

You can have both a title and a subtitle:

```yaml
title: Pixels and their Neighbours
subtitle: A Tutorial on Finite Volume
```



### Authors and Affiliations

You can add both author and affiliations lists, each author should have a `name`, and can optionally add `orcid`, `email`, and `affiliations`. The affiliations are just content that is put in superscript, e.g. `"1,2"`, have corresponding identifiers in the top level `affiliations` list, which requires both an `id` and a `name`. If you wish to include any additional information in the affiliation (e.g. an address, department, etc.), it is content and can have whatever you want in it.

```yaml
authors:
  - name: Rowan Cockett
    orcid: 0000-0002-7859-8394
    email: rowan@curvenote.com
    affiliations: 1,2,🖂
  - name: Lindsey Heagy
    orcid: 0000-0002-1551-5926
    affiliations: 1
  - name: Douglas Oldenburg
    orcid: 0000-0002-4327-2124
    affiliations: 1
institute:
  - id: 1
    name: University of British Columbia
  - id: 2
    name: Curvenote Inc.
```

For other information that you wish to affiliate with a specific author, you can use the `affiliations` field with any identifier you like (e.g. `†` or `🖂`) and then use the margin content or affiliations fields on the preprint to explain what it means.


### Abstract and keywords

You can include one or more abstracts as well as keywords. For a simple `abstract` the default title used is "Abstract" and you can include it with:

```yaml
abstract: |
  Whatever content you want to include. You should be able to use *markdown* as well.
keyword: [Finite Volume, Tutorial, Reproducible Research]
```

### Margin content

The content on the first page is customizable. The first content is the `kind`, for example, "Original Research", "Review Article", "Retrospective" etc. And then the `pub-date`, which is by default the date you compiled the document if not specified. Note that currently you must use the Typst `datetime` format[^date].

[^date]: I'd prefer to use raw strings here, but I'm confused about how Quarto handles dates and how to pass them to Typst which has its own builtin date handling functions. So this is subject to change.

```yaml
kind: "Notebook Tutorial"
pub-date: "`datetime(year: 2023, month: 08, day: 21)`{=typst}"
```

You can also set `pub-date` to be a dictionary or list of dictionaries with `title` and `date` as the two required keys. The first date will be bolded as well as used in the document metadata and auto `short-citation`.

```yaml
kind: "Notebook Tutorial"
pub-date: 
  - title: Published
    date: "`datetime(year: 2023, month: 08, day: 21)`{=typst}"
  - title: Accepted
    date: "`datetime(year: 2022, month: 12, day: 10)`{=typst}"
  - title: "Submitted"
    date: "`datetime(year: 2022, month: 12, day: 10)`{=typst}"
```

### Headers and Footers

You can control the headers and footer by providing the following information:

```yaml
open-access: true # not implemented yet
doi: 10.1190/tle35080703.1
venue: "`[ar#text(fill: red.darken(20%))[X]iv]`{=typst}"
short-title: Finite Volume Tutorial
short-citation: auto #not implemented yet
```

The first page will show an open-access statement and the `doi` if available. For DOIs, only include the actual identifier, not the URL portions:


Subsequent pages will show the `short-title` and `short-citation`. If the citation is `auto` (the default) it will be created in APA formatting using the paper authors.


The footers show the `venue` (e.g. the journal or preprint repository) the `date` (which is by default `today()`) as well as the page count.



### Incomplete


### Margins

The rest of the margin content can be set with `margin` property, which takes a `title` and `content`.

```yaml
margin-content:
  - title: Key Points
    content: |
      * key point 1 is *important*.
      * key point 2 is also important.
      * this is the third idea.
  - title: Corresponding Author
    content: 🖂 [rowan@curvenote.com](mailto:rowan@curvenote.com)
  - title: Data Statement
    content: Associated notebooks are available on [GitHub]("https://github.com/simpeg/tle-finitevolume") and can be run online with [MyBinder]("http://mybinder.org/repo/simpeg/tle-finitevolume").
  - title: Funding
    content: Funding was provided by the Vanier Award to each of Cockett and Heagy.
  - title: Competing Interests
    content: The authors declare no competing interests.
```

You can use the margin property for things like funding, data availability statements, explicit correspondence requests, key points, conflict of interest statements, etc.


### Bibliography

typst handles the bibliography. `bibliography` points to the .bib file and `biblio-style` specifies the styling[^biblio]. Available styles are documented by Typst: https://typst.app/docs/reference/model/bibliography/. In text references and cross references should be written as specified in pandoc/Quarto: (https://quarto.org/docs/authoring/footnotes-and-citations.html#sec-citations).

[^biblio]: This might change in the future to using (or providing the option of) pandoc's builtin citeproc. 

```yaml
bibliography: main.bib
biblio-style: apa 
```