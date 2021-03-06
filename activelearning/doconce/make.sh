#!/bin/sh -x
set -x
sh -x ./clean.sh

system ()
{
    # Run operating system command and if failure, report and abort
    "$@"
    if [ $? -ne 0 ]; then
	echo "make.sh: unsuccessful command $@"
	echo "abort!"
        exit 1
    fi
}

language="German"
options=" --encoding=utf-8 --siunits --language=$language"
name=index
public="elite:/home/mimeiners/public_html"


# Note: since Doconce syntax is demonstrated inside !bc/!ec
# blocks we need a few fixes

editfix ()
{
    # Fix selected backslashes inside verbatim envirs that doconce has added
    # (only a problem when we want to show full doconce code with
    # labels in !bc-!ec envirs as in this presentation).
    # doconce replace '\label{this:section}' 'label{this:section}' $1
    # doconce replace '\label{fig1}' 'label{fig1}' $1
    # doconce replace '\label{demo' 'label{demo' $1
    doconce replace '\title' '\title[ELK]' $1
    doconce replace '\author' '\author[M. Meiners]' $1
    doconce replace '\institute' '\institute[HSB]' $1
    doconce replace '[plain,fragile]' '[fragile]' $1
}

# HTML5 Slides
# html=${name}-reveal-grey
# system doconce format html ${name} --pygments_html_style=native --keep_pygments_html_bg --html_links_in_new_window --html_output=$html $options
# system doconce slides_html ${html} reveal --html_slide_theme=darkgray --copyright=everypage --html_footer_logo=HSB_RGB

# html=${name}-reveal-moon
# doconce format html ${name} --pygments_html_style=fruity --keep_pygments_html_bg SLIDE_TYPE=reveal SLIDE_THEME=moon --html_output=$html $options
# doconce slides_html ${html} reveal --html_slide_theme=moon --copyright=everypage --html_footer_logo=HSB_RGB
# editfix $html.html

# html=${name}-reveal-blue
# system doconce format html ${name} --pygments_html_style=default --keep_pygments_html_bg  SLIDE_TYPE=reveal SLIDE_THEME=sky --html_output=$html $options
# system doconce slides_html ${html} reveal --html_slide_theme=sky --copyright=everypage --html_footer_logo=HSB_RGB
# system doconce format html $name --pygments_html_style=default --keep_pygments_html_bg --html_links_in_new_window --html_output=$html ${options}
# system doconce slides_html $html reveal --html_slide_theme=simple --copyright=titlepage
# editfix $html.html

# deck.js HTML5 slides
# html=${name}-deck-blue
# doconce format html ${name} --pygments_html_style=default --keep_pygments_html_bg SLIDE_TYPE=deck SLIDE_THEME=sandstone.firefox --html_output=$html $options
# doconce slides_html ${html} deck --html_slide_theme=sandstone.firefox --copyright=everypage --html_footer_logo=HSB_RGB
# system doconce format html $name --pygments_html_style=native --keep_pygments_html_bg --html_links_in_new_window --html_output=$html ${options}
# system doconce slides_html $html deck --html_slide_theme=sandstone.default --copyright=everypage
# editfix $html.html

# Plain HTML documents
html=${name}
style=bootswatch_spacelab
# system doconce format html $name --pygments_html_style=perldoc --html_style=solarized3 --html_links_in_new_window --html_output=$html $options
system doconce format html ${name} \
       --pygments_html_style=emacs \
       --html_style=${style} \
       --html_links_in_new_window \
       --html_output=${html} \
       ${options}
# system doconce split_html ${html}.html --nav_button=gray2,bottom \
#       --font_size=slides --copyright=titlepage

# # Construct AULIS folder for export
# mkdir -p ${name}/fig
# cp ../../fig/${name}*.png ./${name}/fig
# cp ../../fig/${name}*.jpg ./${name}/fig
# cp ../../fig/${name}*.svg ./${name}/fig
# cp ${name}.html ./${name}/
# ln -s ${name}.html ./${name}/index.html
# cp ._*.html ./${name}
# # zip -r ${name}.zip ./${name}
# find ./${name} -type f -exec chmod 644 {} \;
# find ./${name} -type d -exec chmod 755 {} \;
# rsync -rtvluz -e ssh ./${name} ${public}/elk/ --delete-before

# LaTeX Beamer slides
# theme=hsb_blue
# system doconce format pdflatex ${name} \
#     --latex_title_layout=beamer \
#     --latex_code_style=pyg \
#     --latex_movie=href \
#     ${options}
# system doconce slides_beamer ${name} \
#        --beamer_slide_theme=$theme
# editfix ${name}.tex
# system pdflatex -shell-escape ${name}
# system bibtex ${name}
# system pdflatex -shell-escape ${name}
# system pdflatex -shell-escape ${name}
# mv -f ${name}.pdf ${name}-beamer.pdf
# system doconce lightclean

# Beamer handouts
# theme=hsb_blue
# system doconce format pdflatex ${name} \
#       --latex_title_layout=beamer \
#       --latex_code_style=pyg \
#       --latex_movie=href \
#       ${options}
# system doconce slides_beamer ${name} \
#       --beamer_slide_theme=$theme \
#       --handout  # note --handout!
# editfix ${name}.tex
# system pdflatex -shell-escape ${name}
# system bibtex ${name}
# system pdflatex -shell-escape ${name}
# system pdflatex -shell-escape ${name}
# # Merge slides to 1x2 per page
# pdfnup --nup 1x2 --frame true \
#       --no-landscape --paper a4paper \
#       --column true \
#       --delta "1cm 1cm" --scale 0.9 \
#       --outfile ${name}_handout1x2.pdf \
#       ${name}.pdf
# system doconce lightclean

# LaTeX documents
system doconce format pdflatex ${name} \
       --latex_code_style=pyg \
       --latex_font=bera \
       --latex_movie=href \
       ${options}
system pdflatex -shell-escape ${name}
# system bibtex ${name}
# system pdflatex -shell-escape ${name}
system pdflatex -shell-escape ${name}
mv -f ${name}.pdf ${name}-minted.pdf
# system doconce lightclean

# PDF for screen viewing with an alternative look from classic LaTeX
# doconce format pdflatex ${name} \
#	--latex_font=cmbright \
#	--latex_preamble=preamble.tex \
#	--latex_admon=yellowicon '--latex_admon_color=yellow!5' \
#	--latex_fancy_header --latex_code_style=pyg --siunits \
#	--latex_section_headings=blue --latex_colored_table_rows=blue \
#	--latex_movie=href ${options}

# doconce replace 'begin{abstract}' 'begin{quote}\small' ${name}.tex
# doconce replace 'end{abstract}' 'end{quote}' ${name}.tex

# system rm -rf ${name}.aux
# system pdflatex -shell-escape ${name}
# system bibtex ${name}
# system pdflatex -shell-escape ${name}
# system pdflatex -shell-escape ${name}
# mv -f ${name}.pdf ${name}-screen.pdf
# system doconce lightclean

# PDF for printing
# doconce format pdflatex ${name} \
# 	--device=paper \
# 	--latex_font=cmbright \
# 	--latex_title_layout=titlepage --latex_admon=grayicon \
# 	--latex_code_style=pyg --siunits \
# 	--latex_movie=href ${options}

# system pdflatex -shell-escape ${name}
# system bibtex ${name}
# system pdflatex -shell-escape ${name}
# system pdflatex -shell-escape ${name}
# mv -f ${name}.pdf ${name}-printing.pdf
# system doconce lightclean

# XeLaTeX documents
# system doconce format pdflatex ${name} --xelatex --latex_code_style=lst ${options}
# system xelatex ${name}

# Sphinx document
# theme=bootstrap
# theme=pyramid
theme=scipy_lectures
# theme=hsb2
system doconce format sphinx ${name}
# system doconce split_rst ${name}
# system doconce replace "language = " "language = 'de' "
system doconce sphinx_dir theme=${theme} ${name}
system python2 automake_sphinx.py

# Markdown (pandoc extended)
# system doconce format pandoc ${name} ${options}
# system doconce md2latex ${name}
# system doconce md2html ${name}
# system mv ${name}.html ${name}-pandoc.html
# system pandoc -s -S ${name}.md -o ${name}.docx
# system pandoc ${name}.md -o ${name}.odt
# system pandoc ${name}.md --pdf-engine=xelatex -o ${name}-pandoc.pdf
# system odpdown --break-master=break_slide \
#        --content-master=content_slides \
#        ${name}.md \
#        hsb_template.odp \
#        ${name}.odp

# using pandoc to go from LaTeX to MS Word or HTML
# system doconce format latex ${name} ${options}
# system ptex2tex ${name}
# system doconce replace '\Verb!' '\verb!' ${name}.tex
# system pandoc -f latex -t docx -o ${name}.docx ${name}.tex


# IPython notebook
# ipynb_figure=imgtag
# ipynb_movie=ipynb
# ipynb_admon=hrule
# nbv=3
# system doconce format ipynb ${name} --encoding=utf-8
# pygmentize -l json -o ${name}.ipynb.html ${name}.ipynb

# doconce format ipynb ${name} \
# 	--encoding=utf-8
# 	--no_preprocess \
# 	--ipynb_figure=${ipynb_figure} ipynb_figure=${ipynb_figure} \
# 	--ipynb_movie=${ipynb_movie} ipynb_movie=${ipynb_movie} \
# 	--ipynb_admon=${ipynb_admon} ipynb_admon=${ipynb_admon} \
# 	--ipynb_version=$nbv \
# Must fix instructions since doconce performs certain actions for
# some of the code segments we demonstrate
# doconce subst '" +%matplotlib inline\\n",\n +" +\\n",\n +' '' ${name}.ipynb
# doconce subst '"import numpy as np\\n"', '"%matplotlib inline\\n",\n "import numpy as np\\n",' ${name}.ipynb
# doconce subst 'Plot\. \\\\label' 'Plot. label' ${name}.ipynb


# system doconce format mwiki ${name} ${options}
# system doconce format pandoc ${name} ${options}
# system pandoc -R -t mediawiki -o ${name}.mwk --toc ${name}.md

# Make HTML Bibliography
# system publish export papers.bib
# system bibtex2html -a -nokeys -nobibsource -header "Bibliographie Modul 3.3 ELK" papers.bib
