# PSU-regExUtil

simple ruby tool to process a csv file with headers (id, text) with a reg ex, 

outputs a headerless csv as follows:
id, match1, match2 ...

regular expresions can be defined and named in regex.txt and usage is as follows
regexUtils <csv file path> <regex name> <output file path>
 
default output will be saved in './' with generated file name
if no regex name provided a default regex will be used

this module is intended as a solution to extract regions of interest in texts, for example what comes after a certain word which indicates the place of an event.
