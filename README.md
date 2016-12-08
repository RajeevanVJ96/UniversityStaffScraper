# UniversityStaffScraper
This is a Haskell script that uses the Scalpel web scraping package in Haskell to scrape the names and telephones from the web page of Computing Science staff at the University of Glasgow. 

Installing and Running the script(in linux)

1. Install GHC 8.0.1 and a package manager such as Cabal(used when making the script) onto your computer.
2. Choose the directory you wish to run the scraper and navigate there and do the following commands in terminal:
   'cabal sandbox init'
   'cabal update'
   'cabal install scalpel'
   These commandss create a cabal sandbox inside your chosen directory and any packages you install through cabal
   will be installed and only work within the sandbox ie won't work anywhere outside this directory. The last command
   installs Scalpel.
3. Enter the sandbox by giving the command 'cabal repl'.
4. Load the scraper file by doing ':l scraper.hs' inside the ghci to load and compile the script. Make sure the scraper.hs is
   in the same directory when you load it.
5. If it compiles without errors then type 'main' to run the main method which will run the script whereby scraping the urls
   and return the names and phone numbers of staff and output the results to a directory.tex file.
6. To get a pdf version of the tex file, run the command 'pdflatex directory.tex'. You may need to install texlive-latex-base
   first which is done by 'sudo apt install texlive-latex-base'.
   
