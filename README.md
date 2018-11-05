# madewithlove-cli
A script file for cli testing of url redirects using https://htaccess.madewithlove.be/ online htaccess testing tool

## Installation
- download and save the script in a folder in which you are going to test your htaccess file.
- give the script executive rights

`chmod +x ./mwlove.sh`

## Usage

run the helper for more info,

`.mwlove.sh -h`

you can also use this script to batch test urls.  Simply save a list of urls in a file,

`
http://url1
http://url2
http://url3
`

and pipe this file into the script,

`cat urls.txt | ./mwlove.sh -f ./test.htaccess`

this will output a list of rediected urls which you further save into a file if need be,

`cat urls.txt | ./mwlove.sh -f ./test.htaccess > results.txt`
