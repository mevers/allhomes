## Test environments

- R-hub windows-x86_64-devel (r-devel)
- R-hub ubuntu-gcc-release (r-release)
- R-hub fedora-clang-devel (r-devel)

## R CMD check results

- There were no ERRORs & WARNINGs
- NOTE: 
    > New submission

    Response: This is correct.
- NOTE:
    >  Possibly misspelled words in DESCRIPTION:  
    >    Allhomes (6:141)  
    >    NSW (6:293)
    
    Response: These are not misspelled words.
- NOTE:
   >  checking for detritus in the temp directory ... NOTE  
   >  Found the following files/directories:  
   >    'lastMiKTeXException'

   Response: This happens only on windows-x86_64-devel (r-devel); according to [rhub issue #503](https://github.com/r-hub/rhub/issues/503) can be ignored.
- NOTE:
    >  checking HTML version of manual ... NOTE  
    >  Skipping checking HTML validation: no command 'tidy' found

    Response: This happens only on fedora-clang-devel (r-devel); this seems to be an issue with `tidy` not being on the PATH of the Linux server, and not with the package.

## Individual response to requests

Submission reviewed by Benjamin Altmann on 8 Sep 2022:

> The Description field is intended to be a (one paragraph) description  
> of what the package does and why it may be useful.  
> Please add more details about the package functionality and implemented  
> methods in your Description text.  

I have expanded the description.

>   
> Please provide a link to the used webservices to the description field  
> of your DESCRIPTION file in the form  
> <http:...> or <https:...>  
> with angle brackets for auto-linking and no space after 'http:' and  
> 'https:'.  

I have wrapped the relevant link in angle brackets as per request.

>  
> Please put functions which download data in \donttest{}. I believe you have them in \dontrun{}?  
> Unless the function needs user specific information(e.g. missing API keys, passwords, etc).  

I have replaced all `\dontrun{}` calls with `\donttest{}` as per request.

>   
> Please fix and resubmit.

---

# Previous cran-comments

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
