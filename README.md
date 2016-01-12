This repository contains a small LaTex and bash script system, which can be used to create
exercise sheets and exams for courses.

**Note:** Currently only German is supported and very little is customisable with regards to 
what text is printed on the cover of the exam or exercise sheets. This is planned to be generalised
very soon.

# Setup
Copy ``examples/common.sh`` and ``examples/common.tex`` to the directory of ``neues_blatt.sh``.
Take a look at these two files and adjust them for your needs.

# Create a new sheet
Just run ``./neues_blatt.sh``

# Create a new exam
Just run ``./neues_blatt.sh --exam``.

Note that this will also symlink the file ``extra_exam_sheets.tex`` into the exam directory. 
Using this file one can create an exam-specific header for extra pages the students might need to write on during the exam. 
The advantage is that each Latex run includes a random number at the lower right such that nobody can prepare such a sheet
which is already filled out with some solutions and bring it to the exam (which would be easy in the case of just white paper)
