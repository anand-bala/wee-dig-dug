%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                              %
% The following preamble was originally written by the CSE 379 course staff at %
% the University at Buffalo as a template for lab documentation.               %
%                                                                              %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


\documentclass [10pt]{article}
\NeedsTeXFormat{LaTeX2e}
\ProvidesClass{docs}[2017/05/06 Class for writing documentation and reports]

\oddsidemargin=0.0cm
\textwidth=16.5cm
\textheight=22.8cm
\topmargin=-1.0cm

\RequirePackage[utf8]{inputenc}
\RequirePackage{tabularx}
\RequirePackage{fancyhdr}
\RequirePackage{multirow}
\RequirePackage{mathtools}% Loads amsmath
\RequirePackage[hidelinks]{hyperref}
\RequirePackage{graphicx}
\RequirePackage{float}

\pagestyle{fancy}
\fancyhf{}
\renewcommand{\headrulewidth}{1pt}

\RequirePackage{listings}

% the following is needed for syntax highlighting
\RequirePackage{color}
\RequirePackage{lstlangarm} %arm keywords for syntax highlighting
\definecolor{dkgreen}{rgb}{0,0.6,0}
\definecolor{gray}{rgb}{0.5,0.5,0.5}
\definecolor{mauve}{rgb}{0.58,0,0.82}

\lstset{ %
language=[ARM]{Assembler},      % the language of the code
basicstyle=\normalsize,         % the size of the fonts that are used for the code
numbers=left,                   % where to put the line-numbers
numberstyle=\footnotesize\color{gray},  % the style that is used for the line-numbers
stepnumber=1,                   % the step between two line-numbers. If it's 1, each line
% will be numbered
numbersep=5pt,                  % how far the line-numbers are from the code
backgroundcolor=\color{white},  % choose the background color. You must add \RequirePackage{color}
showspaces=false,               % show spaces adding particular underscores
showstringspaces=false,         % underline spaces within strings
showtabs=false,                 % show tabs within strings adding particular underscores
frame=single,                   % adds a frame around the code
rulecolor=\color{white},        % if not set, the frame-color may be changed on line-breaks within not-black text (e.g. commens (green here))
tabsize=2,                      % sets default tabsize to 2 spaces
captionpos=b,                   % sets the caption-position to bottom
breaklines=true,                % sets automatic line breaking
breakatwhitespace=false,        % sets if automatic breaks should only happen at whitespace
title=\lstname,                 % show the filename of files included with \lstinputlisting;
% also try caption instead of title
keywordstyle=\color{blue},          % keyword style
commentstyle=\color{gray},       % comment style
stringstyle=\color{mauve},         % string literal style
escapeinside={\%*}{*)},            % if you want to add a comment within your code
morekeywords={*,...}               % if you want to add more keywords to the set
}



