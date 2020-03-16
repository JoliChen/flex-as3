#!/bin/bash

ADT="/Users/joli/Applications/Adobe/Adobe Flash Builder 4.7/sdks/4.6.0/bin/adt"
"${ADT}" -package -target ane miss.ane extension.xml -swc miss.swc -platform Android-ARM miss.jar library.swf -platform default library.swf