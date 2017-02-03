\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{myclass}[2015/09/29 zettel]

%% Options for the article base class:
\DeclareOption{10pt}{
  \PassOptionsToClass{\CurrentOption}{article}
}

\DeclareOption{12pt}{
  \PassOptionsToClass{\CurrentOption}{article}
}

%% Show solutions or not?
\newif\if@showsolutions\@showsolutionsfalse
\DeclareOption{showsolutions}{
  \@showsolutionstrue
}

%% Show points or not?
\newif\if@awardpoints\@awardpointstrue
\DeclareOption{nopoints}{
  \@awardpointsfalse
}

%% Show date and time or not?
\newif\if@showdatetime\@showdatetimetrue
\DeclareOption{nodatetime}{
  \@showdatetimefalse
}

%% Exam mode or not?
\newif\if@exam\@examfalse
\DeclareOption{exam}{
  \@examtrue
}

%% Fallback
\DeclareOption*{
  \ClassWarning{zettel}{Unknown option '\CurrentOption'}
}

%% Execute default options
\ExecuteOptions{10pt}

%% Process given options
\ProcessOptions\relax

%% Load base
\LoadClass[a4paper]{article}

%-------------------------------------
%% Load packages we require:
\usepackage{forloop}

% maths and formatting
\usepackage{amsthm}
\usepackage[tight]{units}
\usepackage{color}

% TODO hardcoded geometry!
\usepackage[left=3.5cm,right=3.5cm,top=4cm,bottom=4cm]{geometry}

\if@showsolutions
	\usepackage[nosolutionfiles]{answers}
\else
	\usepackage{answers}
\fi

%-------------------------------------

% Variables and commands to be overwritten by user
\newcommand{\dateout}{\{Renewcommand \textbackslash dateout\}}
\newcommand{\dateback}{\{Renewcommand \textbackslash dateback\}}
\newcommand{\course}{\{Renewcommand \textbackslash course\}}
\newcommand{\semester}{\{Renewcommand \textbackslash semester\}}
\newcommand{\sheetno}{\{Renewcommand \textbackslash sheetno\}}
\newcommand{\lecturer}{\{Renewcommand \textbackslash lecturer\}}

% Some default pointtype:
\newcommand{\pointname}{P}

% Counter for sheet number
\newcounter{sheetno}

% Theorem definition for Aufgabe
\theoremstyle{definition}
\newtheorem{ex}{Aufgabe}[sheetno]

% Setup file and environments where solutions go to 
\Newassociation{sol}{Solution}{ans}
\renewenvironment{Solution}[1]{\color{red} \begin{paragraph}{L\"osung #1.}}{\end{paragraph}}

% Theorem definition for Notes:
\newtheorem*{nte}{Beachten Sie}

% Change enumerate items:
\renewcommand{\labelenumi}{(\alph{enumi})}
\renewcommand{\labelenumii}{(\roman{enumii})}

% Macro to produce the point table
\newcommand{\pointtable}{%
	\newread\filein
	\openin\filein=exercises.points
	\immediate\read\filein to\fileline
	\setcounter{totalex}{\fileline}
	\immediate\read\filein to\fileline
	\setcounter{totalpoints}{\fileline}
	\closein\filein
	%
	% draw a nice table to put in the marks
	\newcounter{ai}
	\begin{tabular}{*{\value{totalex}}{c|}c}
	\forloop{ai}{1}{\value{ai} < \value{totalex}}{ %
		\arabic{ai} & %
	}%
	\ifthenelse{\value{totalex} = 0}{}{ %
		\arabic{totalex} & %
	}%
	$\Sigma$ \\
	\hline
	\forloop{ai}{1}{\value{ai} < \value{totalex}}{%
		\hspace{1.5em} & %
	}
	\ifthenelse{\value{totalex} = 0}{}{%
		\hspace{1.5em} & %
	}
	\quad \quad / \totalpnt\\[0.5em]
	\end{tabular}%
}

% Command to produce the title of the sheet
\newcommand{\thesheettitle}{%
	\if@exam%
		\textbf{\sheetno. Klausur zur Vorlesung}%
	\else%
		\textbf{\"Ubungsblatt \sheetno}%
	\fi%
}

% The basic environment in which the sheet lives:
\newenvironment{zettel}{%
	% Set solution output file and sheet number counter:
	\Opensolutionfile{ans}[solution\sheetno]
	\setcounter{sheetno}{\sheetno}

	\if@exam
		% Exam title page
		\thispagestyle{empty}
		\vspace{2cm}
		\begin{center}
			\thesheettitle\\[0.3cm]
			\Large{\course \ \semester}\\[0.3cm]
			\normalsize{\lecturer}
		\end{center}

		\if@showdatetime
			\vspace{1cm}
			{
				\hfill
				\normalsize
				\begin{tabular}{rcr}
				ungef. Beginn:       &       & \dateout \\
				ungef. Ende:         &       & \dateback \\[0.5cm]
				\end{tabular}
			} \\[2cm]
		\else
			\vspace{3cm}
		\fi
		Bitte beachten Sie die folgenden Hinweise zur Klausur:
		\begin{itemize}
			\item Auf den folgenden Seiten finden Sie die Klausurfragen. 
				Sie d\"urfen diese \textbf{erst lesen, sobald die Klausurzeit l\"auft}.
			\item Vervollst\"andigen Sie auf diesem Deckblatt Name und Matrikelnummer.
			\item Die Benutzung von Formelsammlungen, B\"uchern, Taschenrechnern und anderen elektronischen Hilfsmitteln
				 ist untersagt und wird als T\"auschungsversuch gewertet.
			\item Sollte der Platz des Klausurbogens nicht ausreichen, bekommen Sie von uns \textbf{zus\"atzliches Papier}. 
				Achten Sie sorgf\"altig darauf, dass Sie \textbf{auf jedem zus\"atzlichen Blatt} 
				Ihren \textbf{Namen}, Ihre \textbf{Matrikelnummer}
				und die Nummern der auf diesem Blatt bearbeiteten \textbf{Aufgaben} angeben.
			\item Verdeutlichen Sie bei allen Aufgaben Ihren \textbf{L\"osungsweg} oder \textbf{begr\"unden} Sie Ihre Antworten.
		\end{itemize}
		\vfill
		\begin{center}
			\Large
			\begin{tabular}{rcr}
			Name:         & \quad & \hspace{15em} \\
			Matrikel-Nr:  &       & \hspace{8em}
			\end{tabular}

			\vspace{1cm}
			{
			\LARGE
			\pointtable
			}
			\vspace{1cm}
		\end{center}
		\newpage
	\else
		% Exercise title page
		\begin{center}
			\Large{\course \ \semester}\\[0.3cm]
			\normalsize{\lecturer}\\[0.6cm]
			\thesheettitle
			\hfill
			\if@showdatetime%
			\begin{tabular}{rcr}
			Ausgabe: & \quad & \dateout \\
			Abgabe:  &       & \dateback
			\end{tabular}\\[0.3cm]
			\else%
			~
			\fi%

			% Read restored stuff from file
			\if@awardpoints
				\pointtable\\[0.3cm]
			\fi
		
			\hrulefill\\[0.5cm]
		\end{center}
	\fi
}{%
	\if@awardpoints
		% Write points and current value of ex to file for next latex run
		\newwrite\fileout
		\immediate\openout\fileout=exercises.points
		\immediate\write\fileout{\arabic{ex}}
		\immediate\write\fileout{\arabic{points}}
		\immediate\closeout\fileout
	\fi
}
%-------------------------------------

% total number of exercises (as stored in file)
\newcounter{totalex}[sheetno]

% point management
\newcounter{points}[sheetno] % counter to accumulate no of points
\newcounter{totalpoints}[sheetno] % counter to be filled with stored total no of points
% spit out no of points in formatted way and add to counter
\newcommand{\pntadd}[1]{\unit[#1]{\pointname}\addtocounter{points}{#1}}
% just spit out no of points in formatted way
\newcommand{\pnt}[1]{\unit[#1]{\pointname}}
% spit out the total no of points in a formatted way
\newcommand{\totalpnt}{\unit[\arabic{totalpoints}]{\pointname}}
% Show the number of points on the rhs of the page
\newcommand{\pntrhs}[1]{\hfill(\pnt{#1})}

\endinput
