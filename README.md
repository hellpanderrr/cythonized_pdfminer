PDFMiner
========
Trying to Cythonize PDFMiner's bottlenecks.

The bottlenecks:
=
1) https://github.com/hellpanderrr/cythonized_pdfminer/blob/master/pdfminer/utils.py#L320

Current solution: https://github.com/hellpanderrr/cythonized_pdfminer/blob/master/pdfminer/plane.pyx

2) https://github.com/hellpanderrr/cythonized_pdfminer/blob/master/pdfminer/layout.py

Current solution: https://github.com/hellpanderrr/cythonized_pdfminer/blob/master/pdfminer/layout_c.pyx

Current productivity gain:
=
200-300% on text-heavy pdfs
