# PSU-regExUtil

simple ruby tool to process a csv file with headers (id, text) with a reg ex,

outputs a headerless csv as follows:
id, match1, match2 ...

regular expresions can be defined and named in regex.txt and usage is as follows
regexUtils <csv file path> <regex name> <output file path>

default output will be saved in './' with generated file name
if no regex name provided a default regex will be used

this module is intended as a solution to extract regions of interest in texts, for example what comes after a certain word which indicates the place of an event.

ADDED:
black box functions to handle required stuff. just pass it what it needs.
Fun => processes a CSV as required

Line => returns matches in a line as a hashmap
JSON => returns JSONobject w matches

note Line and Json receive a regex hashmap {'name' => /regex/}

It is recommended to understand regular expressions:
https://www.rubyguides.com/2015/06/ruby-regex/
https://regexr.com
