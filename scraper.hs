-- Name: Rajeevan Vijayakumar
-- Email: 2080123v@student.gla.ac.uk
{-# LANGUAGE OverloadedStrings #-}
import Data.List(isInfixOf)
import Data.List.Split
import Data.Maybe
import Text.HTML.Scalpel
import Control.Monad
import Control.Applicative
import Text.LaTeX

main :: IO()
main = do
    res <- scrapeURL "http://www.gla.ac.uk/schools/computing/staff/" scrapeStaffURL                     -- scrapes all the URLs that have ending as the name of staff ie /jeremysinger
    res1 <- scrapeURL "http://www.gla.ac.uk/schools/computing/staff/" scrapeActionStaffURL              -- scrapes all the URLs that have ending as !action ie /?action=person&id=4edceae28591
    let format = fmap (\x -> join x) res                                                                -- goes through the first URL scrape and removes the monadic structure from each element
    staffNormal <- sequence $ (fmap (mapM extractDetails) format)                                       -- takes the now formatted list of URLs and scrapes each one for the name and phone numbers
    let format1 = fmap (\x -> join x) res1
    staffAction <- sequence $ (fmap (mapM extractActionDetails) format1)                                -- same thing is done for the urls that end with ?action
    let delnon = fmap (map deleteNothing) fromJust staffNormal                                          -- remove the Nothing values by replacing them with null from the list containing the tuple pairs of name and phone number
    let delnon1 = fmap (map deleteNothing) fromJust staffAction                                         -- same as above but for the ?action urls
    let total = (filter(not . null) delnon) ++ (filter(not . null) delnon1)                             -- Concatenates boths URL lists while at the same time remove the null values.
    let normal = map toNormal total                                                                     -- Turn the tuple pairs into strings separated by commas ie name , phone. done so to print to txt file below
    print normal
    writeFile "output.txt" $ unlines normal                                                             -- print list to text file and using the file, create a tex file called directory.tex
    text <- execLaTeXT doc
    renderFile "directory.tex" text



doc :: Monad m => LaTeXT m ()                                                                           -- creation of the tex file, taken from hatex tutorial
doc = do
      thePreamble
      document theBody

thePreamble :: Monad m => LaTeXT m ()
thePreamble = do
   documentclass [] article
   usepackage [] "verbatim"
   author "Rajeevan Vijayakumar - 2080123v"
   title "Staff Details"

theBody :: Monad m => LaTeXT m ()
theBody = do
   maketitle
   raw "\\verbatiminput{output.txt}"


toNormal :: [(String,String)] -> String                                                        -- takes a tuple and turns it into a string where x is the first and y is second member of tuple
toNormal [(x,y)] = x++" , "++y                                                                 -- and they are concatenated together with a comma separating them.

deleteNothing :: Maybe [(String, String)] -> [(String, String)]                                -- removes the Nothing as well as an monadic structure to return a list of list string tuples
deleteNothing (Nothing) = []                                                                   -- if a Nothing is found then it is replaced with an empty list ie null or if a just x is found
deleteNothing (Just x) = x                                                                     -- the monadic part, Just is removed and replaced with just the tuple.

scrapeStaffURL :: Scraper String [[String]]                                                     -- scrapes the given URL ie for all the  'a' tags
scrapeStaffURL =
    chroots ("a") scrapeEachURL

scrapeActionStaffURL :: Scraper String [[String]]                                                        -- scrapes the given URL ie for all the  'a' tags
scrapeActionStaffURL=
    chroots ("a") scrapeEachActionURL

extractDetails :: String -> IO(Maybe[(String,String)])                                            -- given a URL in string form, scrapes the URL for the name and phone, called in the main function
extractDetails x =
    scrapeURL x scrapeNamePhone

extractActionDetails :: String -> IO(Maybe[(String,String)])                                      -- given a URL in string form, scrapes the URL for the name and phone, called in the main function
extractActionDetails x =
    scrapeURL x scrapeActionNamePhone

scrapeEachURL :: Scraper String [String]                                                                 -- in the 'a', all the text in the 'href' tag is selected and stored in str
scrapeEachURL = do                                                                                       -- isInfixOf is used to select everything in hfef(ie str) after the given string
    str <- attr "href" anySelector                                                                       -- the string + str is returned back as a string list.
    guard ("schools/computing/staff/" `isInfixOf` str)
    return ["www.gla.ac.uk" ++ str]

scrapeEachActionURL :: Scraper String [String]                                                           -- same as the function above but for the staff urls with ?action
scrapeEachActionURL = do
    str <- attr "href" anySelector
    guard ("?action" `isInfixOf` str )
    return ["www.gla.ac.uk/schools/computing/staff/" ++ str]

scrapeNamePhone :: Scraper String [(String, String)]                                                     -- scrapes the name and phone for each url ending with staffs name
scrapeNamePhone = do                                                                                     -- for name, the text inside the h1 tag that has the class named responsivestyle is returned
     name <- text $ "h1" @: [hasClass "responsivestyle"]                                                 -- for phone, the text in the div that contains the id=sp_contactInfo is returned as a string and
     phone <- text ("div" @: ["id" @= "sp_contactInfo"])                                                 -- phone number is extracted from that string
     let finalPhone = extractPhoneNumber phone
     if ((length finalPhone) > 0) then                                                                   -- checks if the user has a phone number. if they do, return a list tuple contain their name and their number
        return [(name, extractPhoneNumber phone)]                                                        -- extracted from the sp_contactinfo string using a function below
     else                                                                                                -- if they do not have a number then an empty list is returned
        return []

scrapeActionNamePhone :: Scraper String [(String, String)]                                               -- same as the function above but for the staff urls with ?action. It contains
scrapeActionNamePhone = do                                                                               -- different tags to search for phone number.
     name <- text $ "h1"
     phone <- text ("p" @: ["style" @= "margin: 0 0 10px 25px; padding: 5px; color: ##333;" ])
     let finalPhone = extractPhoneNumber phone
     if ((length finalPhone) > 0) then
        return [(name, extractPhoneNumber phone)]
     else
        return []

extractPhoneNumber :: String -> String                                                                   -- This function extracts the phone number from a given string
extractPhoneNumber telestring = do                                                                       -- looks for the occurrence of 'telephone' and takes out the number using
      if("\ntelephone: " `isInfixOf` telestring)                                                         -- the formatNumber function below else returns an empty string
         then (formatNumber telestring)
         else ("")

formatNumber :: String -> String                                                                         -- extracts the phone number after the occurrence of the 'telephone' occurence
formatNumber telestring = (splitOn "\n" ((splitOn ": " telestring)!!1))!!0







