# quarto-lapreprint Format

This is a typst template for quarto users. The original typst template is from [LaPreprint](https://github.com/LaPreprint/typst) and has been slightly modified for use in quarto.


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
    affiliations: 1,2
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


Note that the orcid and email icons are actually aligned to the text. Details, details!

For other information that you wish to affiliate with a specific author, you can use the `affiliations` field with any identifier you like (e.g. `†`) and then use the margin content or affiliations fields on the preprint to explain what it means.

Corresponding author information will be added to the margin for authors with an email address.

### Abstract and keywords

You can include one or more abstracts as well as keywords. For a simple `abstract` the default title used is "Abstract" and you can include it with:

```yaml
abstract: |
  Whatever content you want to include. You should be able to use *markdown* as well.
keyword: [Finite Volume, Tutorial, Reproducible Research]
```

### Margin content

The content on the first page is customizable. The first content is the `kind`, for example, "Original Research", "Review Article", "Retrospective" etc. And then the `pub-date`, which is by default the date you compiled the document.

```yaml
kind: "Notebook Tutorial"
pub-date: "`datetime(year: 2023, month: 08, day: 21)`{=typst}"
```

You can also set `pub-date` to be a dictionary or list of dictionaries with `title` and `date` as the two required keys. The first date will be bolded as well as used in the document metadata and auto `short-citation`.

```yaml
kind: "Notebook Tutorial"
pub-date: '`((title: "Published", date: datetime(year: 2023, month: 08, day: 21)), (title: "Accepted", date: datetime(year: 2022, month: 12, day: 10)), (title: "Submitted", date: datetime(year: 2022, month: 12, day: 10)))`{=typst}'
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


**margins**

The rest of the margin content can be set with `margin` property, which takes a `title` and `content`, content is required, however the title is optional.

```typst
margin: (
  (
    title: "Correspondence to",
    content: [
      Rowan Cockett\
      #link("mailto:rowan@curvenote.com")[rowan\@curvenote.com]
    ],
  ),
  // ... other properties
)
```

You can use the margin property for things like funding, data availability statements, explicit correspondence requests, key points, conflict of interest statements, etc.


**bibliography**

typst handles the bibliography.

```yaml
bibliography: main.bib
style: apa #not implemented yet
```