// Some definitions presupposed by pandoc's typst output.
#let blockquote(body) = [
  #set text( size: 0.92em )
  #block(inset: (left: 1.5em, top: 0.2em, bottom: 0.2em))[#body]
]

#let horizontalrule = [
  #line(start: (25%,0%), end: (75%,0%))
]

#let endnote(num, contents) = [
  #stack(dir: ltr, spacing: 3pt, super[#num], contents)
]

#show terms: it => {
  it.children
    .map(child => [
      #strong[#child.term]
      #block(inset: (left: 1.5em, top: -0.4em))[#child.description]
      ])
    .join()
}

// Some quarto-specific definitions.

#show raw.where(block: true): block.with(
    fill: luma(230), 
    width: 100%, 
    inset: 8pt, 
    radius: 2pt
  )

#let block_with_new_content(old_block, new_content) = {
  let d = (:)
  let fields = old_block.fields()
  fields.remove("body")
  if fields.at("below", default: none) != none {
    // TODO: this is a hack because below is a "synthesized element"
    // according to the experts in the typst discord...
    fields.below = fields.below.amount
  }
  return block.with(..fields)(new_content)
}

#let empty(v) = {
  if type(v) == "string" {
    // two dollar signs here because we're technically inside
    // a Pandoc template :grimace:
    v.matches(regex("^\\s*$")).at(0, default: none) != none
  } else if type(v) == "content" {
    if v.at("text", default: none) != none {
      return empty(v.text)
    }
    for child in v.at("children", default: ()) {
      if not empty(child) {
        return false
      }
    }
    return true
  }

}

#show figure: it => {
  if type(it.kind) != "string" {
    return it
  }
  let kind_match = it.kind.matches(regex("^quarto-callout-(.*)")).at(0, default: none)
  if kind_match == none {
    return it
  }
  let kind = kind_match.captures.at(0, default: "other")
  kind = upper(kind.first()) + kind.slice(1)
  // now we pull apart the callout and reassemble it with the crossref name and counter

  // when we cleanup pandoc's emitted code to avoid spaces this will have to change
  let old_callout = it.body.children.at(1).body.children.at(1)
  let old_title_block = old_callout.body.children.at(0)
  let old_title = old_title_block.body.body.children.at(2)

  // TODO use custom separator if available
  let new_title = if empty(old_title) {
    [#kind #it.counter.display()]
  } else {
    [#kind #it.counter.display(): #old_title]
  }

  let new_title_block = block_with_new_content(
    old_title_block, 
    block_with_new_content(
      old_title_block.body, 
      old_title_block.body.body.children.at(0) +
      old_title_block.body.body.children.at(1) +
      new_title))

  block_with_new_content(old_callout,
    new_title_block +
    old_callout.body.children.at(1))
}

#show ref: it => locate(loc => {
  let target = query(it.target, loc).first()
  if it.at("supplement", default: none) == none {
    it
    return
  }

  let sup = it.supplement.text.matches(regex("^45127368-afa1-446a-820f-fc64c546b2c5%(.*)")).at(0, default: none)
  if sup != none {
    let parent_id = sup.captures.first()
    let parent_figure = query(label(parent_id), loc).first()
    let parent_location = parent_figure.location()

    let counters = numbering(
      parent_figure.at("numbering"), 
      ..parent_figure.at("counter").at(parent_location))
      
    let subcounter = numbering(
      target.at("numbering"),
      ..target.at("counter").at(target.location()))
    
    // NOTE there's a nonbreaking space in the block below
    link(target.location(), [#parent_figure.at("supplement") #counters#subcounter])
  } else {
    it
  }
})

// 2023-10-09: #fa-icon("fa-info") is not working, so we'll eval "#fa-info()" instead
#let callout(body: [], title: "Callout", background_color: rgb("#dddddd"), icon: none, icon_color: black) = {
  block(
    breakable: false, 
    fill: background_color, 
    stroke: (paint: icon_color, thickness: 0.5pt, cap: "round"), 
    width: 100%, 
    radius: 2pt,
    block(
      inset: 1pt,
      width: 100%, 
      below: 0pt, 
      block(
        fill: background_color, 
        width: 100%, 
        inset: 8pt)[#text(icon_color, weight: 900)[#icon] #title]) +
      block(
        inset: 1pt, 
        width: 100%, 
        block(fill: white, width: 100%, inset: 8pt, body)))
}


// This is the LaPreprint template licensed under MIT from:
// - https://github.com/LaPreprint/typst


#let quarto-lapreprint(
  // The paper's title.
  title: "Paper Title",
  subtitle: none,

  // An array of authors. For each author you can specify a name, orcid, and affiliations.
  // affiliations should be content, e.g. "1", which is shown in superscript and should match the affiliations list.
  // Everything but but the name is optional.
  authors: (),
  // This is the affiliations list. Include an id and `name` in each affiliation. These are shown below the authors.
  affiliations: (),
  // The paper's abstract. Can be omitted if you don't have one.
  abstract: none,
  // The short-title is shown in the running header
  short-title: none,
  // The short-citation is shown in the running header, if set to auto it will show the author(s) and the year in APA format.
  short-citation: auto,
  // The venue is show in the footer
  venue: none,
  // An image path that is shown in the top right of the page. Can also be content.
  logo: none,
  // A DOI link, shown in the header on the first page. Should be just the DOI, e.g. `10.10123/123456` ,not a URL
  doi: none,
  heading-numbering: "1.a.i",
  // Show an Open Access badge on the first page, and support open science, default is true, because that is what the default should be.
  open-access: true,
  // A list of keywords to display after the abstract
  keywords: (),
  // The "kind" of the content, e.g. "Original Research", this is shown as the title of the margin content on the first page.
  kind: none,
  // Content to put on the margin of the first page
  // Should be a list of dicts with `title` and `content`
  margin: (),
  paper-size: "us-letter",
  // A color for the theme of the document
  theme: blue.darken(30%),
  // Date published, for example, when you publish your preprint to an archive server.
  // To hide the date, set this to `none`. You can also supply a list of dicts with `title` and `date`.
  date: datetime.today(),
  // Feel free to change this, the font applies to the whole document
  font-face: none,
  // The path to a bibliography file if you want to cite some external works.
  bibliography-file: none,
  bibliography-style: "apa",
  // The paper's content.
  body
) = {

  /* Logos */
  let orcidSvg = ```<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 24 24"> <path fill="#AECD54" d="M21.8,12c0,5.4-4.4,9.8-9.8,9.8S2.2,17.4,2.2,12S6.6,2.2,12,2.2S21.8,6.6,21.8,12z M8.2,5.8c-0.4,0-0.8,0.3-0.8,0.8s0.3,0.8,0.8,0.8S9,7,9,6.6S8.7,5.8,8.2,5.8z M10.5,15.4h1.2v-6c0,0-0.5,0,1.8,0s3.3,1.4,3.3,3s-1.5,3-3.3,3s-1.9,0-1.9,0H10.5v1.1H9V8.3H7.7v8.2h2.9c0,0-0.3,0,3,0s4.5-2.2,4.5-4.1s-1.2-4.1-4.3-4.1s-3.2,0-3.2,0L10.5,15.4z"/></svg>```.text

  let spacer = text(fill: gray)[#h(8pt) | #h(8pt)]

  let dates;
  if (type(date) == "datetime") {
    dates = ((title: "Published", date: date),)
  }else if (type(date) == "dictionary") {
    dates = (date,)
  } else {
    dates = date
  }
  date = dates.at(0).date

  // Create a short-citation, e.g. Cockett et al., 2023
  let year = if (date != none) { ", " + date.display("[year]") }
  if (short-citation == auto and authors.len() == 1) {
    short-citation = authors.at(0).name.split(" ").last() + year
  } else if (short-citation == auto and authors.len() == 2) {
    short-citation = authors.at(0).name.split(" ").last() + " & " + authors.at(1).name.split(" ").last() + year
  } else if (short-citation == auto and authors.len() > 2) {
    short-citation = authors.at(0).name.split(" ").last() + " " + emph("et al.") + year
  }
  
  // Set document metadata.
  set document(title: title, author: authors.map(author => author.name))

  show link: it => [#text(fill: theme)[#it]]
  show ref: it => [#text(fill: theme)[#it]]

  set page(
    paper: paper-size,
    margin: (left: 25%),
    header: locate(loc => {
      if(loc.page() == 1) {
        let headers = (
          if (open-access) {smallcaps[Open Access]},
          if (doi != none) { link("https://doi.org/" + doi, "https://doi.org/" + doi)}
        )
        return align(left, text(size: 8pt, fill: gray, headers.filter(header => header != none).join(spacer)))
      } else {
        return align(right, text(size: 8pt, fill: gray.darken(50%),
          (short-title, short-citation).join(spacer)
        ))
      }
    }),
    footer: block(
      width: 100%,
      stroke: (top: 1pt + gray),
      inset: (top: 8pt, right: 2pt),
      [
        #grid(columns: (75%, 25%),
          align(left, text(size: 9pt, fill: gray.darken(50%),
              (
                if(venue != none) {emph(venue)},
                if(date != none) {date.display("[month repr:long] [day], [year]")}
              ).filter(t => t != none).join(spacer)
          )),
          align(right)[
            #text(
              size: 9pt, fill: gray.darken(50%)
            )[
              #counter(page).display() of #locate((loc) => {counter(page).final(loc).first()})
            ]
          ]
        )
      ]
    )
  )

  // Set the body font.
  set text(font: font-face, size: 10pt)
  // Configure equation numbering and spacing.
  set math.equation(numbering: "(1)")
  show math.equation: set block(spacing: 1em)

  // Configure lists.
  set enum(indent: 10pt, body-indent: 9pt)
  set list(indent: 10pt, body-indent: 9pt)

  // Configure headings.
  set heading(numbering: heading-numbering)
  show heading: it => locate(loc => {
    // Find out the final number of the heading counter.
    let levels = counter(heading).at(loc)
    set text(10pt, weight: 400)
    if it.level == 1 [
      // First-level headings are centered smallcaps.
      // We don't want to number of the acknowledgment section.
      #let is-ack = it.body in ([Acknowledgment], [Acknowledgement])
      // #set align(center)
      #set text(if is-ack { 10pt } else { 12pt })
      #show: smallcaps
      #v(20pt, weak: true)
      #if it.numbering != none and not is-ack {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(13.75pt, weak: true)
    ] else if it.level == 2 [
      // Second-level headings are run-ins.
      #set par(first-line-indent: 0pt)
      #set text(style: "italic")
      #v(10pt, weak: true)
      #if it.numbering != none {
        numbering(heading-numbering, ..levels)
        [.]
        h(7pt, weak: true)
      }
      #it.body
      #v(10pt, weak: true)
    ] else [
      // Third level headings are run-ins too, but different.
      #if it.level == 3 {
        numbering(heading-numbering, ..levels)
        [. ]
      }
      _#(it.body):_
    ]
  })


  if (logo != none) {
    place(
      top,
      dx: -33%,
      float: false,
      box(
        width: 27%,
        {
          if (type(logo) == "content") {
            logo
          } else {
            image(logo, width: 100%)
          }
        },
      ),
    )
  }


  // Title and subtitle
  box(inset: (bottom: 2pt), text(17pt, weight: "bold", fill: theme, title))
  if subtitle != none {
    parbreak()
    box(text(14pt, fill: gray.darken(30%), subtitle))
  }
  // Authors and affiliations
  if authors.len() > 0 {
    box(inset: (y: 10pt), {
      authors.map(author => {
        text(11pt, weight: "semibold", author.name)
        h(1pt)
        if "affiliations" in author {
          super(author.affiliations)
        }
        if "orcid" in author {
          link("https://orcid.org/" + author.orcid)[#box(height: 1.1em, baseline: 13.5%)[#image.decode(orcidSvg)]]
        }
      }).join(", ", last: ", and ")
    })
  }
  if affiliations.len() > 0 {
    box(inset: (bottom: 10pt), {
      affiliations.map(affiliation => {
        super(affiliation.id)
        h(1pt)
        affiliation.name
      }).join(", ")
    })
  }


  place(
    left + bottom,
    dx: -33%,
    dy: -10pt,
    box(width: 27%, {
      if (kind != none) {
        show par: set block(spacing: 0em)
        text(11pt, fill: theme, weight: "semibold", smallcaps(kind))
        parbreak()
      }
      if (dates != none) {
        let formatted-dates

        grid(columns: (40%, 60%), gutter: 7pt,
          ..dates.zip(range(dates.len())).map((formatted-dates) => {
            let d = formatted-dates.at(0);
            let i = formatted-dates.at(1);
            let weight = "light"
            if (i == 0) {
              weight = "bold"
            }
            return (
              text(size: 7pt, fill: theme, weight: weight, d.title),
              text(size: 7pt, d.date.display("[month repr:short] [day], [year]"))
            )
          }).flatten()
        )
      }
      v(2em)
      grid(columns: 1, gutter: 2em, ..margin.map(side => {
        text(size: 7pt, {
          if ("title" in side) {
            text(fill: theme, weight: "bold", side.title)
            [\ ]
          }
          set enum(indent: 0.1em, body-indent: 0.25em)
          set list(indent: 0.1em, body-indent: 0.25em)
          side.content
        })
      }))
    }),
  )


  let abstracts
  if (type(abstract) == "content" or type(abstract) == "string") {
    abstracts = ((title: "Abstract", content: abstract),)
  } else {
    abstracts = abstract
  }

  box(inset: (top: 16pt, bottom: 16pt), stroke: (top: 1pt + gray, bottom: 1pt + gray), {

    abstracts.map(abs => {
      set par(justify: true)
      text(fill: theme, weight: "semibold", size: 9pt, abs.title)
      parbreak()
      abs.content
    }).join(parbreak())
  })
  if (keywords.len() > 0) {
    parbreak()
    text(size: 9pt, {
      text(fill: theme, weight: "semibold", "Keywords")
      h(8pt)
      keywords.join(", ")
    })
  }
  v(10pt)

  show par: set block(spacing: 1.5em)

  // Display the paper's contents.
  body

  if (bibliography-file != none) {
    show bibliography: set text(8pt)
    bibliography(bibliography-file, title: text(10pt, "References"), style: bibliography-style)
  }
}
// Typst custom formats typically consist of a 'typst-template.typ' (which is
// the source code for a typst template) and a 'typst-show.typ' which calls the
// template's function (forwarding Pandoc metadata values as required)
//
// This is an example 'typst-show.typ' file (based on the default template  
// that ships with Quarto). It calls the typst function named 'article' which 
// is defined in the 'typst-template.typ' file. 
//
// If you are creating or packaging a custom typst template you will likely
// want to replace this file and 'typst-template.typ' entirely. You can find
// documentation on creating typst templates here and some examples here:
//   - https://typst.app/docs/tutorial/making-a-template/
//   - https://github.com/typst/templates

#show: quarto-lapreprint.with(
  title: "Pixels and their Neighbours",
  subtitle: "A Tutorial on Finite Volume",
  short-title: "Finite Volume Tutorial",
  venue: [ar#text(fill: red.darken(20%))[X]iv],
  // This is relative to the template file
  // When importing normally, you should be able to use it relative to this file.
  logo: "files/logo.png",
  doi: "10.1190/tle35080703.1",
  theme: red.darken(50%),
  authors: (
    ( name: "Rowan Cockett",
      affiliations: "1,2", "true",
      orcid: "0000-0002-7859-8394" ),
    ( name: "Lindsey Heagy",
      affiliations: "1", "true",
      orcid: "0000-0002-1551-5926" ),
    ( name: "Douglas Oldenburg",
      affiliations: "1",
      orcid: "0000-0002-4327-2124" ),
    ),

  date: ((title: "Published", date: datetime(year: 2023, month: 08, day: 21)), (title: "Accepted", date: datetime(year: 2022, month: 12, day: 10)), (title: "Submitted", date: datetime(year: 2022, month: 12, day: 10))),

  affiliations: (
    ( id: "1",
      name: "University of British Columbia"
    ),
    ( id: "2",
      name: "Curvenote Inc."
    ),
    ),

  keywords: (
        "Finite Volume", 
        "Tutorial", 
        "Reproducible Research"  ),
  open-access: true,

  font-face: "Fira Sans",
  abstract: [#lorem(100)],
  kind: [Notebook Tutorial],

  margin: (
          (
        title: "Key Points",
        content: [- key point 1 is #emph[important];.
- key point 2 is also important.
- this is the third idea.

]
      ),
          (
        title: "Data Statement",
        content: [Associated notebooks are available on #link("%22https://github.com/simpeg/tle-finitevolume%22")[GitHub] and can be run online with #link("%22http://mybinder.org/repo/simpeg/tle-finitevolume%22")[MyBinder];.]
      ),
          (
        title: "Funding",
        content: [Funding was provided by the Vanier Award to each of Cockett and Heagy.]
      ),
          (
        title: "Competing Interests",
        content: [The authors declare no competing interests.]
      ),
      ),

  bibliography-file: "main.bib",


)


= DC Resistivity
<sec-dc-resistivity>
DC resistivity surveys obtain information about subsurface electrical conductivity, $sigma$. This physical property is often diagnostic in mineral exploration, geotechnical, environmental and hydrogeologic problems, where the target of interest has a significant electrical conductivity contrast from the background. In a DC resistivity survey, steady state currents are set up in the subsurface by injecting current through a positive electrode and completing the circuit with a return electrode \(@fig-dc-setup).

#figure([
#box(width: 60%,image("files/dc-setup.png"))
], caption: figure.caption(
position: bottom, 
[
Setup of a DC resistivity survey.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-dc-setup>


// You can put this after the content that fits on the first page to set the margins back to full-width
#set page(margin: auto)
The equations for DC resistivity are derived in \(@fig-dc-eqns). Conservation of charge \(which can be derived by taking the divergence of Ampere’s law at steady state) connects the divergence of the current density everywhere in space to the source term which consists of two point sources, one positive and one negative.

The flow of current sets up electric fields according to Ohm’s law, which relates current density to electric fields through the electrical conductivity. From Faraday’s law for steady state fields, we can describe the electric field in terms of a scalar potential, $phi.alt$, which we sample at potential electrodes to obtain data in the form of potential differences.

#figure([
#box(width: 100%,image("files/dc-eqns.png"))
], caption: figure.caption(
position: bottom, 
[
Derivation of the DC resistivity equations.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-dc-eqns>


To set up a solvable system of equations, we need the same number of unknowns as equations, in this case two unknowns \(one scalar, $phi.alt$, and one vector $arrow(j)$ and two first-order equations \(one scalar, one vector).

In this tutorial, we walk through setting up these first order equations in finite volume in three steps: \(1) defining where the variables live on the mesh; \(2) looking at a single cell to define the discrete divergence and the weak formulation; and \(3) moving from a cell based view to the entire mesh to construct and solve the resulting matrix system. The notebooks included with this tutorial leverage the #link("%22http://simpeg.xyz/%22")[SimPEG] package, which extends the methods discussed here to various mesh types.

= Where do things live?
<sec-where-do-things-live>
To bring our continuous equations into the computer, we need to discretize the earth and represent it using a finite\(!) set of numbers. In this tutorial we will explain the discretization in 2D and generalize to 3D in the notebooks. A 2D \(or 3D!) mesh is used to divide up space, and we can represent functions \(fields, parameters, etc.) on this mesh at a few discrete places: the nodes, edges, faces, or cell centers. For consistency between 2D and 3D we refer to faces having area and cells having volume, regardless of their dimensionality. Nodes and cell centers naturally hold scalar quantities while edges and faces have implied directionality and therefore naturally describe vectors. The conductivity, $sigma$, changes as a function of space, and is likely to have discontinuities \(e.g.~if we cross a geologic boundary). As such, we will represent the conductivity as a constant over each cell, and discretize it at the center of the cell. The electrical current density, $arrow(j)$, will be continuous across conductivity interfaces, and therefore, we will represent it on the faces of each cell. Remember that $arrow(j)$ is a vector; the direction of it is implied by the mesh definition \(i.e.~in $x$, $y$ or $z$), so we can store the array $bold(j)$ as #emph[scalars] that live on the face and inherit the face’s normal. When $arrow(j)$ is defined on the faces of a cell the potential, $phi.alt$, will be put on the cell centers \(since $arrow(j)$ is related to $phi.alt$ through spatial derivatives, it allows us to approximate centered derivatives leading to a staggered, second-order discretization). Once we have the functions placed on our mesh, we look at a single cell to discretize each first order equation. For simplicity in this tutorial we will choose to have all of the faces of our mesh be aligned with our spatial axes \($x$, $y$ or $z$), the extension to curvilinear meshes will be presented in the supporting notebooks.

#figure([
#box(width: 100%,image("files/mesh.png"))
], caption: figure.caption(
position: bottom, 
[
Anatomy of a finite volume cell.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-mesh>


= One cell at a time
<sec-one-cell-at-a-time>
To discretize the first order differential equations we consider a single cell in the mesh and we will work through the discrete description of equations \(1) and \(2) over that cell.

== In and out
<sec-1-in-and-out>
#figure([
#box(width: 100%,image("files/divergence.png"))
], caption: figure.caption(
position: bottom, 
[
Geometrical definition of the divergence and the discretization.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-div>


So we have half of the equation discretized - the left hand side. Now we need to take care of the source: it contains two dirac delta functions - these are infinite at their origins, $r_((s^(+)))$ and $r_((s^(-)))$. However, the volume integral of a delta function #emph[is] well defined: it is #emph[unity] if the volume contains the origin of the delta function otherwise it is #emph[zero];.

As such, we can integrate both sides of the equation over the volume enclosed by the cell. Since $bold(D) bold(j)$ is constant over the cell, the integral is simply a multiplication by the volume of the cell $"v"bold(D) bold(j)$. The integral of the source is zero unless one of the source electrodes is located inside the cell, in which case it is $q = plus.minus I$. Now we have a discrete description of equation 1 over a single cell:

$ "v"bold(D) bold(j) = q $ <eq:div>
== Scalar equations only, please
<sec-id-2-scalar-equations-only-please>
@eq:div is a vector equation, so really it is two or three equations involving multiple components of $arrow(j)$. We want to work with a single scalar equation, allow for anisotropic physical properties, and potentially work with non-axis-aligned meshes - how do we do this?! We can use the #emph[weak formulation] where we take the inner product \($integral arrow(a) dot.op arrow(b) d v$) of the equation with a generic face function, $arrow(f)$. This reduces requirements of differentiability on the original equation and also allows us to consider tensor anisotropy or curvilinear meshes.

In @fig-weak-formulation, we visually walk through the discretization of equation \(b). On the left hand side, a dot product requires a #emph[single] cartesian vector, $bold(j_x comma j_y)$. However, we have a $j$ defined on each face \(2 $j_x$ and 2 $j_y$ in 2D!). There are many different ways to evaluate this inner product: we could approximate the integral using trapezoidal, midpoint or higher order approximations. A simple method is to break the integral into four sections \(or 8 in 3D) and apply the midpoint rule for each section using the closest $bold(j)$ components to compose a cartesian vector. A $bold(P)_i$ matrix \(size $2 times 4$) is used to pick out the appropriate faces and compose the corresponding vector \(these matrices are shown with colors corresponding to the appropriate face in the figure). On the right hand side, we use a vector identity to integrate by parts. The second term will cancel over the entire mesh \(as the normals of adjacent cell faces point in opposite directions) and $phi.alt$ on mesh boundary faces are zero by the Dirichlet boundary condition. This leaves us with the divergence, which we already know how to do!

#figure([
#box(width: 90%,image("files/weak-formulation.png"))
], caption: figure.caption(
position: bottom, 
[
Discretization using the weak formulation and inner products.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-weak-formulation>


The final step is to recognize that, now discretized, we can cancel the general face function $bold(f)$ and transpose the result \(for convention’s sake):

$ frac(1, 4) sum_(i = 1)^4 bold(P)_i^top sqrt(v) bold(Sigma)^(-1) sqrt(v) bold(P)_i bold(j) = bold(D)^top v phi $
= All together now
<sec-all-together-now>
We have now discretized the two first order equations over a single cell. What is left is to assemble and solve the DC system over the entire mesh. To implement the divergence on the full mesh, the stencil of $plus.minus$1’s must index into $bold(j)$ on the entire mesh \(instead of four elements). Although this can be done in a `for-loop`, it is conceptually, and often computationally, easier to create this stencil using nested Kronecker Products \(see notebook). The volume and area terms in the divergence get expanded to diagonal matrices, and we multiply them together to get the discrete divergence operator. The discretization of the #emph[face] inner product can be abstracted to a function, $bold(M)_f (sigma^(-1))$, that completes the inner product on the entire mesh at once. The main difference when implementing this is the $bold(P)$ matrices, which must index into the entire mesh. With the necessary operators defined for both equations on the entire mesh, we are left with two discrete equations:

$ "diag"(bold(v)) bold(D) bold(j) = bold(q) $
$ bold(M)_f (sigma^(-1)) bold(j) = bold(D)^top "diag"(bold(v)) phi $
Note that now all variables are defined over the entire mesh. We could solve this coupled system or we could eliminate $bold(j)$ and solve for $phi.alt$ directly \(a smaller, second-order system).

$ "diag"(bold(v)) bold(D) bold(M)_f (sigma^(-1))^(-1) bold(D)^top "diag"(bold(v)) phi = bold(q) $
By solving this system matrix, we obtain a solution for the electric potential $phi.alt$ everywhere in the domain. Creating predicted data from this requires an interpolation to the electrode locations and subtraction to obtain potential differences!

#figure([
#box(width: 90%,image("files/dc-results.png"))
], caption: figure.caption(
position: bottom, 
[
Electric potential on \(a) tensor and \(b) curvilinear meshes.
]), 
kind: "quarto-float-fig", 
supplement: "Figure", 
numbering: "1", 
)
<fig-results>


Moving from continuous equations to their discrete analogues is fundamental in geophysical simulations. In this tutorial, we have started from a continuous description of the governing equations for the DC resistivity problem, selected locations on the mesh to discretize the continuous functions, constructed differential operators by considering one cell at a time, assembled and solved the discrete DC equations. Composing the finite volume system in this way allows us to move to different meshes and incorporate various types of boundary conditions that are often necessary when solving these equations in practice.

Associated notebooks are available on #link("%22https://github.com/simpeg/tle-finitevolume%22")[GitHub] and can be run online with #link("%22http://mybinder.org/repo/simpeg/tle-finitevolume%22")[MyBinder];.

All article content, except where otherwise noted \(including republished material), is licensed under a Creative Commons Attribution 3.0 Unported License \(CC BY-SA). See #link("%22https://creativecommons.org/licenses/by-sa/3.0/%22")[https:\/\/creativecommons.org/licenses/by-sa/3.0/];. Distribution or reproduction of this work in whole or in part commercially or noncommercially requires full attribution of the #cite(<Cockett_2016>);, including its digital object identifier \(DOI). Derivatives of this work must carry the same license. All rights reserved.
